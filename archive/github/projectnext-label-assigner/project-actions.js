const { graphql } = require("@octokit/graphql");
const core = require('@actions/core');
const github = require('@actions/github');
const fetch = require('node-fetch')

const _ = require('lodash');

class ProjectActions {

    async addItemToProject(octokit, context, projectNumber) {
        const { itemType, itemNumber, itemId } = context;

        if (!projectNumber) {
            throw new Error(`projectNumber is required.`);
        }

        if (!itemId) {
            throw new Error(`itemId is required.`);
        }

        const projectId = await this.findProjectId(octokit, context, projectNumber);
        if (!projectId) {
            throw new Error(`Error adding item to project: projectNumber ${projectNumber} not found`);
        }

        console.log(`Creating a new item for ${itemType} number ${itemNumber}, ID ${itemId} in project [${projectNumber}], owner "${context.owner}"`);
        await this.createItem(octokit, projectId, itemId);
    }

    async removeIssuesFromProject(octokit, context, projectNumber) {
        const { itemType, itemNumber } = context;

        if (!projectNumber) {
            throw new Error(`projectNumber is required.`);
        }

        if (!itemNumber) {
            throw new Error(`itemNumber is required.`);
        }

        if (itemType !== 'Issue') {
            // TODO Implement support for pull requests some day
            throw new Error(`only type 'Issue' is supported for removal`);
        }

        const projectId = await this.findProjectId(octokit, context, projectNumber);
        if (!projectId) {
            throw new Error(`Error removing item from project: projectNumber ${projectNumber} not found`);
        }

        // 'itemNumber is the issue number in this context
        console.log(`findProjectItemsForIssueNumber(octokit, ${context.owner}, ${context.repo}, ${itemNumber})`);
        const projectItemIds = await this.findProjectItemsForIssueNumber(octokit, context.owner, context.repo, itemNumber);

        console.log(`Removing items ${JSON.stringify(projectItemIds)} from project [${projectNumber}], owner "${context.owner}"`);
        projectItemIds.forEach(async (projectItemId) => {
            await this.removeItem(octokit, projectId, projectItemId);
        });
    }

    async removeItem(octokit, projectId, itemId) {
        try {
            const mutation = `
                mutation deleteItem($projectId: ID!, $itemId: ID!) {
                    deleteProjectV2Item(input: {
                      projectId: $projectId
                      itemId: $itemId
                    }) {
                      deletedItemId
                    }
                  }`
            const params = {projectId: projectId, itemId: itemId};
            console.log(`Delete item mutation:\n${mutation}`);
            console.log(`Params: ${JSON.stringify(params)}`);
            // Octokit will throw an error if GraphQL returns any error messages
            const response = await octokit(mutation, params);
            console.log(`Remove item response:\n${JSON.stringify(response)}`);
            return _.get(response, 'deleteProjectV2Item.deletedItemId');
        } catch (error) {
            throw new Error(`Error removing item with ID '${itemId}' in project ${projectId}: ${error.message}`);
        }
    }

    async findProjectId(octokit, context, projectNumber) {
        try {
            const query = `query findProjectId($owner: String!, $projectNumber: Int!) {
                organization(login: $owner) {
                    projectV2(number: $projectNumber) {
                        id
                    }
                }
            }`;
            const params = { owner: context.owner, projectNumber: projectNumber };
            console.log(`Query for project ID:\n${query}`);
            console.log(`Params: ${JSON.stringify(params)}`);
            const response = await octokit(query, params);
            console.log(`Response from query for project ID:\n${JSON.stringify(response, null, 2)}`);
            return _.get(response, 'organization.projectV2.id');
        } catch (error) {
            throw new Error(`Error querying project ID for project number ${projectNumber}: ${error.message} \n error.request: ${JSON.stringify(error.request)}`);
        }
    }

    async findProjectItemsForIssueNumber(octokit, owner, repo, issueNumber) {
        try {
            const query = `query findProjectItemsForIssueNumber($owner: String!, $repo: String!, $issueNumber:Int!) {
                viewer {
                  organization(login:$owner) {
                    repository(name:$repo) {
                      issue(number:$issueNumber) {
                        projectItems(first:50) {
                          nodes {
                            id
                          }
                        }
                      }
                    }
                  }
                }
              }`;
            const params = { owner: owner, repo: repo, issueNumber: issueNumber };
            console.log(`Query for findItemByIssueNumber:\n${query}`);
            console.log(`Params: ${JSON.stringify(params)}`);
            const response = await octokit(query, params);
            console.log(`Response from query for project items:\n${JSON.stringify(response, null, 2)}`);
            const projectItems = _.get(response, 'viewer.organization.repository.issue.projectItems.nodes') || [];
            if (projectItems.length == 50) {
                throw new Error(`Too many project items for issue number ${issueNumber}`);
            }
            const projectItemIds = projectItems.map((item) =>  {
                return item['id'];
            });
            return projectItemIds;
        } catch (error) {
            throw new Error(`Error querying project items for issue number ${issueNumber}: ${error.message} \n error.request: ${JSON.stringify(error.request)}`);
        }
    }

    async createItem(octokit, projectId, contentId) {
        try {
            const mutation = `
                mutation createItem($projectId: ID!, $contentId: ID!) {
                    addProjectV2ItemById(input: {projectId: $projectId contentId: $contentId}) {
                        item {
                            id
                        }
                    }
                }`;
            console.log(`Create item mutation:\n${mutation}`);
            // Octokit will throw an error if GraphQL returns any error messages
            const response = await octokit(mutation, {projectId: projectId, contentId: contentId});
            console.log(`Create item response:\n${JSON.stringify(response)}`);
            return _.get(response, 'addProjectV2ItemById.item.id');
        } catch (error) {
            throw new Error(`Error creating item for item ID [${contentId}] in project ${projectId}: ${error.message}`);
        }
    }

    normalizedGithubContext(githubContext) {
        const { repository, label, action, issue, pull_request } = githubContext.payload;
        const context = {
            owner: repository && repository.owner && repository.owner.login,
            repo: repository && repository.name,
            label: label && label.name,
            action: action,
        }

        if (githubContext.eventName == "issues") {
            context.itemType = 'Issue';
            context.itemNumber = issue && issue.number;
            context.itemId = issue && issue.node_id;
        }
        else if (githubContext.eventName == "pull_request") {
            context.itemType = 'Pull request';
            context.itemNumber = pull_request && pull_request.number;
            context.itemId = pull_request && pull_request.node_id;
        }
        return context;
    }

    getConfigs() {
        return JSON.parse(core.getInput('config')) || [];
    }

    async run() {
        console.log('Running');

        const baseUrl = process.env.GRAPHQL_API_BASE || 'https://api.github.com'
        const headers = {
            Authorization: `Bearer ${process.env.PAT_TOKEN || process.env.GITHUB_TOKEN}`
        }

        const octokit = graphql.defaults({
            baseUrl,
            headers,
        });

        try {
            const configs = this.getConfigs();
            console.log(`Using config: ${JSON.stringify(configs)}`);
            const context = this.normalizedGithubContext(github.context);
            console.log(`Context: ${JSON.stringify(context)}`);
            if (context.action === "labeled") {
                for (const config of configs) {
                    if (context.label === config.label) {
                        await this.addItemToProject(octokit, context, config.projectNumber);
                    }
                };

            } else if (context.action == "unlabeled") {
                for (const config of configs) {
                    if (context.label === config.label) {
                        await this.removeIssuesFromProject(octokit, context, config.projectNumber);
                    }
                };
            }
        } catch (error) {
            const ghContext = JSON.stringify(github.context, undefined, 2);
            core.setFailed(`Project label assigner action failed with error: ${error.message}\n Event context:\n\n${ghContext}`);
        }
    }
}

module.exports = ProjectActions;
