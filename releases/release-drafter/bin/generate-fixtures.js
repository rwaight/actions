#!/usr/bin/env node

const fs = require('node:fs')
const path = require('node:path')
const fetch = require('node-fetch')
const {
  findCommitsWithAssociatedPullRequestsQuery,
  findCommitsWithPathChangesQuery,
} = require('../lib/commits')

const REPO_NAME = 'release-drafter-test-repo'
const GITHUB_GRAPHQL_API_ENDPOINT = 'https://api.github.com/rwaight/actions'
//const GITHUB_GRAPHQL_API_ENDPOINT = 'https://api.github.com/graphql'
const GITHUB_TOKEN = process.env.GITHUB_TOKEN

if (!GITHUB_TOKEN) {
  throw new Error(
    "GitHub's GraphQL API requires a token. Please pass a valid token (GITHUB_TOKEN) as an env variable, no scopes are required."
  )
}

// the 'owner' for the 'const repos' was 'TimonVS' for all branches except
// for the 'forking' branch, that owner was 'jetersen'
const repos = [
  {
    owner: 'rwaight/actions',
    branch: 'merge-commit',
  },
  {
    owner: 'rwaight/actions',
    branch: 'rebase-merging',
  },
  {
    owner: 'rwaight/actions',
    branch: 'squash-merging',
  },
  {
    owner: 'rwaight/actions',
    branch: 'overlapping-label',
  },
  {
    owner: 'rwaight/actions',
    branch: 'forking',
  },
]

const runQuery = (kind, repo, body) => {
  const options = {
    body,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `bearer ${GITHUB_TOKEN}`,
    },
  }

  fetch(GITHUB_GRAPHQL_API_ENDPOINT, options)
    .then((response) => response.json())
    .then((data) => {
      // hack the generated to reduce massive rewrite inside the tests
      // basically duplicating the possible configs 🤯
      // the '`rwaight/actions-${kind}-${repo.branch}.json`' entry below...
      // was '`graphql-${kind}-${repo.branch}.json`' in release-drafter
      let string = JSON.stringify(data, null, 2).replace(
        /TimonVS\/release-drafter-test-repo/g,
        'rwaight/actions/release-drafter-test-project'
      )
      fs.writeFileSync(
        path.resolve(
          __dirname,
          '../test/fixtures/__generated__',
          `rwaight/actions-${kind}-${repo.branch}.json`
        ),
        string + '\n'
      )
    })
    .catch(console.error)
}

for (const repo of repos) {
  runQuery(
    'commits',
    repo,
    JSON.stringify({
      query: findCommitsWithAssociatedPullRequestsQuery,
      variables: {
        owner: repo.owner,
        name: REPO_NAME,
        targetCommitish: repo.branch,
        withPullRequestBody: true,
        withPullRequestURL: true,
        withBaseRefName: true,
        withHeadRefName: true,
      },
    })
  )

  runQuery(
    'include-null-path',
    repo,
    JSON.stringify({
      query: findCommitsWithPathChangesQuery,
      variables: {
        owner: repo.owner,
        name: REPO_NAME,
        targetCommitish: repo.branch,
        withPullRequestBody: true,
        withPullRequestURL: true,
        withBaseRefName: true,
        withHeadRefName: true,
        path: null,
      },
    })
  )

  runQuery(
    'include-path-src-5.md',
    repo,
    JSON.stringify({
      query: findCommitsWithPathChangesQuery,
      variables: {
        owner: repo.owner,
        name: REPO_NAME,
        targetCommitish: repo.branch,
        withPullRequestBody: true,
        withPullRequestURL: true,
        withBaseRefName: true,
        withHeadRefName: true,
        path: 'src/5.md',
      },
    })
  )
}
