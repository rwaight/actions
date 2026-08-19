import * as core from '@actions/core'
import { DefaultArtifactClient } from '@actions/artifact'
import * as yaml from 'js-yaml'
import * as fs from 'fs'
import * as os from 'os'
import * as path from 'path'

const { endGroup, getInput, startGroup } = core
const log = {
  info: (str: string) => core.info('🛈 ' + str),
  success: (str: string) => core.info('✓ ' + str),
  warning: (str: string, showInReport = true) =>
    core[showInReport ? 'warning' : 'info']('⚠ ' + str),
  error: (str: string, showInReport = true) =>
    core[showInReport ? 'error' : 'info']('✗ ' + str),
  fatal: (str: string) => core.setFailed('✗ ' + str)
}

type GitHubLabel = Record<string, string | boolean | null | undefined>

;(async () => {
  try {
    checkInputs()

    const labels = await fetchLabels()

    await uploadResult(labels)

    await core.summary
      .addHeading('Exported label config')
      .addRaw(`Exported ${labels.length} labels.`)
      .write()

    log.success(
      'Upload complete! You can find the results in the artifacts of this workflow run.'
    )
  } catch (e) {
    log.fatal(e + '')
  }
})()

function checkInputs() {
  if (!getInput('token'))
    log.warning(
      "You're not passing any `token` option: if your repo is private the action will fail with a 404 error from the GitHub API.",
      false
    )

  if (!['true', 'false'].includes(getInput('raw-result')))
    throw 'The only values you can use for the `raw-result` option are `true` and `false`'

  if (!['true', 'false'].includes(getInput('add-aliases')))
    throw 'The only values you can use for the `add-aliases` option are `true` and `false`'
}

function nextPageUrl(linkHeader: string | null): string | null {
  if (!linkHeader) return null
  for (const part of linkHeader.split(',')) {
    const match = part.match(/<([^>]+)>\s*;\s*rel="next"/)
    if (match) return match[1]
  }
  return null
}

async function fetchAllGitHubLabels(): Promise<GitHubLabel[]> {
  const token = getInput('token')
  const repo = process.env.GITHUB_REPOSITORY
  if (!repo) throw 'GITHUB_REPOSITORY is not set'

  const headers: Record<string, string> = {
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'rwaight-actions-export-label-config'
  }
  if (token) headers.Authorization = `Bearer ${token}`

  const labels: GitHubLabel[] = []
  let url: string | null =
    `https://api.github.com/repos/${repo}/labels?per_page=100`
  let page = 1

  while (url) {
    log.info(`Fetching labels page ${page}: ${url}`)
    const response = await fetch(url, { headers })
    if (!response.ok) {
      const body = await response.text()
      throw `GitHub labels API failed with ${response.status}: ${body}`
    }
    const data = await response.json()
    if (!Array.isArray(data)) throw "Can't get label data from GitHub API"
    labels.push(...(data as GitHubLabel[]))
    url = nextPageUrl(response.headers.get('link'))
    page += 1
  }

  return labels
}

async function fetchLabels() {
  startGroup('Labels fetching')

  const rawResult = getInput('raw-result') == 'true',
    addAliases = getInput('add-aliases') == 'true'

  const data = await fetchAllGitHubLabels()

  log.success(`${data.length} labels fetched.`)
  endGroup()

  return rawResult
    ? data
    : data.map((element) => ({
        name: element.name as string,
        color: element.color as string,
        description: (element.description as string) || undefined,
        ...(addAliases ? { aliases: [] } : {})
      }))
}

async function uploadResult(labels: Record<string, unknown>[]) {
  startGroup('Files generation')

  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'export-label-config-'))
  log.info(`Using temp directory: ${tempDir}`)

  const json = JSON.stringify(labels, null, 2),
    yamlText = yaml.dump(labels, { indent: 2, noRefs: true }),
    errors: ('json' | 'yaml')[] = []

  log.info('Writing JSON file...')
  try {
    fs.writeFileSync(path.join(tempDir, 'labels.json'), json)
    log.success('Successfully wrote JSON file.')
  } catch {
    errors.push('json')
  }

  log.info('Writing YAML file...')
  try {
    fs.writeFileSync(path.join(tempDir, 'labels.yaml'), yamlText)
    log.success('Successfully wrote YAML file.')
  } catch {
    errors.push('yaml')
  }

  if (errors.length >= 2) log.fatal("Couldn't write any of the files.")
  else if (errors.length == 1)
    log.error(`Couldn't write ${errors[0].toUpperCase()} file.`)

  endGroup()

  startGroup('Artifact upload')
  const files = ['labels.json', 'labels.yaml'].filter(
    (f) => !errors.includes(f.replace('labels.', '') as 'json' | 'yaml')
  )
  log.info(
    `Uploading ${files.length} file${
      files.length == 1 ? '' : 's'
    }: ${files.join(', ')}`
  )

  const artifact = new DefaultArtifactClient()
  const response = await artifact
    .uploadArtifact(
      'Label config',
      files.map((f) => path.join(tempDir, f)),
      tempDir
    )
    .catch(() => {
      throw "Couldn't upload any file as artifact."
    })

  if (!response || response.id === undefined)
    throw "Couldn't upload any file as artifact."

  log.info('Artifact result: ' + JSON.stringify(response, null, 2))
  log.success(
    `Successfully uploaded files as artifact ${response.id} (${response.size} bytes).`
  )
  endGroup()
}
