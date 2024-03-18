# GraphQL GitHub ProjectV2 API Examples

Example GraphQL queries using the old and new GitHub Projects APIs.

```graphql

# Remember to set the HTTP `Authorization` header to `Basic ghp_...` with your GitHub API token.

# Example query to browse details of items stored in a GitHub ProjectV2
query browseProjectItemDetails
{
  viewer {
    id
    login
    organization(login: "rwaight-org") {

      #projectNext(number: 2) {
      projectV2(number:2) {

        id
        title # Project title

        items(first: 20) {
          nodes {
            databaseId
						id
            content {
              __typename
              ... on Issue {
                # Find associated issue with Project item:
                url
                id
                #... all fields associated with an Issue are available
              }
            }

            # Query custom fields associated with the Project Item:
            fieldValueByName(name:"foo") {
              __typename
              ... on ProjectV2ItemFieldTextValue {
                id
                text
              }
              ... on ProjectV2ItemFieldDateValue {
                id
                date
              }
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                optionId
              }
            }

            # # List all field types
            # fieldValues(first:20) {
            #   nodes {
            #     __typename
            #   }
            # }

            fieldValues(first:20) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue {
                  name
                  id
                }
                ... on ProjectV2ItemFieldLabelValue {
                  labels(first:20) {
                    nodes {
                      id
                      name # e.g. "my-custom-label", "label1", ...

                      # Query a list of PRs that have this label:
                      pullRequests(first:20) {
                        nodes {
                          url
                        }
                      }
                      # Query a list of Issues that have this label:
                      issues(first:20) {
                        nodes {
                          url
                        }
                      }
                    }
                  }
                }
                ... on ProjectV2ItemFieldTextValue {
                  text
                  id
                  updatedAt
                  creator {
                    url
                  }
                }
                ... on ProjectV2ItemFieldMilestoneValue {
                  milestone {
                    id
                  }
                }
                ... on ProjectV2ItemFieldRepositoryValue {
                  repository {
                    id
                    url
                  }
                }
            	}
            }
          }
        }
      }
    }
  }
}

# Old (deprecated) way of finding GitHub projects
query findProjectId($owner: String!, $projectNumber: Int!) {
    organization(login: $owner) {
        projectNext(number: $projectNumber) {
            id
        }
    }
}
# Response:
# {
#   "data": {
#     "organization": {
#       "projectNext": {
#         "id": "MDExOlByb2plY3ROZXh0MTQ0MQ=="
#       }
#     }
#   }
# }

# NEW (supported) ProjectV2 way of finding a new GitHub Project
# Note: !! This returns a different ID than the old findProjectId,
#          even when using the same projectNumber
query NEWfindProjectId($owner: String!, $projectNumber: Int!) {
    organization(login: $owner) {
        projectV2(number: $projectNumber) {
            id
        }
    }
}
# Response:
# {
#   "data": {
#     "organization": {
#       "projectV2": {
#         "id": "PVT_kwDOBQfyVc0FoQ"
#       }
#     }
#   }
# }

# Old, deprecated way of creating a Project Item.
# Must pass a projectId found by calling findProjectId.
# An ID for projectV2 is different from an old projectNext ID.
mutation createItem($projectId: ID!, $contentId: ID!) {
    addProjectNextItem(input: {projectId: $projectId contentId: $contentId}) {
        projectNextItem {
            id
        }
    }
}
# Response:
# {
#   "data": {
#     "addProjectNextItem": {
#       "projectNextItem": {
#         "id": "PNI_lADOBQfyVc0Foc4Afl7c"
#       }
#     }
#   }
# }

# New ProjectV2 way of creating a Project Item from an issue's content ID.
# Note: You must pass a projectId found by calling NEWfindProjectId.
#       An ID for projectV2 is different from an old projectNext project ID.
mutation NEWcreateItem($projectId: ID!, $contentId: ID!) {
  addProjectV2ItemById(input: {projectId: $projectId contentId: $contentId}) {
    item {
      id
    }
  }
}
# Response:
# {
#   "data": {
#     "addProjectV2ItemById": {
#       "item": {
#         "id": "PVTI_lADOBQfyVc0Foc4Afl9P"
#       }
#     }
#   }
# }

# Use this when you need an issue's ID to add it to a project
query findIssueContentId($owner: String!, $repoName: String!) {
  repository(owner:$owner, name:$repoName) {
    issues(states:OPEN, first:20) {
      edges {
        node {
          title
          url
          id
        }
      }
    }
  }
}

# New ProjectV2 way of deleting a project item
mutation NEWdeleteItem($projectId: ID!, $itemId: ID!) {
  deleteProjectV2Item(input: {
    projectId: $projectId
    itemId: $itemId
  }) {
    deletedItemId
  }
}
# Response:
# {
#   "data": {
#     "deleteProjectV2Item": {
#       "deletedItemId": "PVTI_lADOBQfyVc0Foc4Afl9P"
#     }
#   }
# }

# New in ProjectsV2 - You can find an issue's associated ProjectV2 item ID! :D :D
query findProjectItemsForIssueNumber($owner: String!, $repoName: String!, $issueNumber:Int!) {
  viewer {
    organization(login:$owner) {
      repository(name:$repoName) {
        issue(number:$issueNumber) {
          url
          projectItems(first:20) {
            nodes {
              id
            }
          }
        }
      }
    }
  }
}
# Response:
# {
#   "data": {
#     "viewer": {
#       "organization": {
#         "repository": {
#           "issue": {
#             "url": "https://github.com/rwaight-org/repo1/issues/3",
#             "projectItems": {
#               "nodes": [
#                 {
#                   "id": "PVTI_lADOBQfyVc0Foc4Afl9P"
#                 }
#               ]
#             }
#           }
#         }
#       }
#     }
#   }
# }

# Example query to find all issue URLs for the first 20 items in a Project
query findAllIssueUrlsInProject
{
  viewer {
    organization(login: "rwaight-org") {
      projectV2(number:2) {
        items(first: 20) {
          nodes {
            id
            content {
              __typename
              ... on Issue {
                # Find associated issue with Project item:
                url
              }
            }
          }
        }
      }
    }
  }
}
```
