import * as core from '@actions/core'
import * as exec from '@actions/exec'
import {ChangeTypeEnum} from '../changedFiles'
import {Inputs} from '../inputs'
import {
  getDirname,
  getDirnameMaxDepth,
  getFilteredChangedFiles,
  getPreviousGitTag,
  normalizeSeparators,
  warnUnsupportedRESTAPIInputs
} from '../utils'

const originalPlatform = process.platform

function mockedPlatform(platform: string): void {
  Object.defineProperty(process, 'platform', {
    value: platform
  })
}

describe('utils test', () => {
  afterEach(() => {
    Object.defineProperty(process, 'platform', {
      value: originalPlatform
    })
  })

  describe('getDirnameMaxDepth_function', () => {
    // Tests that the function returns the correct dirname when the relative path has multiple directories
    it('test_multiple_directories', () => {
      const result = getDirnameMaxDepth({
        relativePath: 'path/to/some/file',
        dirNamesMaxDepth: 2,
        excludeCurrentDir: false
      })
      expect(result).toEqual('path/to')
    })

    // Tests that the function returns the correct dirname when the relative path has only one directory
    it('test_single_directory', () => {
      const result = getDirnameMaxDepth({
        relativePath: 'path/to',
        dirNamesMaxDepth: 1,
        excludeCurrentDir: false
      })
      expect(result).toEqual('path')
    })

    // Tests that the function returns the correct dirname when the relative path has no directories
    it('test_no_directories', () => {
      const result = getDirnameMaxDepth({
        relativePath: 'file.txt',
        dirNamesMaxDepth: 1,
        excludeCurrentDir: false
      })
      expect(result).toEqual('.')
    })

    // Tests that the function returns the correct dirname when dirNamesMaxDepth is set to a value less than the number of directories in the relative path
    it('test_dirnames_max_depth_less_than_num_directories', () => {
      const result = getDirnameMaxDepth({
        relativePath: 'path/to/some/file',
        dirNamesMaxDepth: 1,
        excludeCurrentDir: false
      })
      expect(result).toEqual('path')
    })

    // Tests that the function returns an empty string when excludeCurrentDir is true and the output is '.'
    it('test_exclude_current_dir_is_true_and_output_is_dot', () => {
      const result = getDirnameMaxDepth({
        relativePath: '.',
        dirNamesMaxDepth: 1,
        excludeCurrentDir: true
      })
      expect(result).toEqual('')
    })

    // Tests that the function returns the correct dirname when the relative path is a Windows drive root and excludeCurrentDir is true
    it('test_windows_drive_root_and_exclude_current_dir_is_true', () => {
      mockedPlatform('win32')
      const result = getDirnameMaxDepth({
        relativePath: 'C:\\',
        dirNamesMaxDepth: 1,
        excludeCurrentDir: true
      })
      expect(result).toEqual('')
    })

    // Tests that getDirnameMaxDepth handles a relative path with a trailing separator correctly
    it('test_trailing_separator', () => {
      const input = {
        relativePath: 'path/to/dir/',
        dirNamesMaxDepth: 2,
        excludeCurrentDir: true
      }
      const expectedOutput = 'path/to'
      const actualOutput = getDirnameMaxDepth(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that getDirnameMaxDepth returns an empty string when excludeCurrentDir is true and the output is '.'
    it('test_trailing_separator_exclude_current_dir', () => {
      const input = {
        relativePath: 'file',
        excludeCurrentDir: true
      }
      const expectedOutput = ''
      const actualOutput = getDirnameMaxDepth(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that getDirnameMaxDepth returns the correct output for a Windows UNC root path
    it('test_windows_unc_root', () => {
      mockedPlatform('win32')
      const input = {
        relativePath: '\\hello',
        dirNamesMaxDepth: 2,
        excludeCurrentDir: true
      }
      const expectedOutput = ''
      expect(getDirnameMaxDepth(input)).toEqual(expectedOutput)
    })

    // Tests that getDirnameMaxDepth returns an empty string when given a Windows UNC root and excludeCurrentDir is true
    it('test_windows_unc_root_exclude_current_dir', () => {
      mockedPlatform('win32')
      const relativePath = '\\hello'
      const result = getDirnameMaxDepth({
        relativePath,
        excludeCurrentDir: true
      })
      expect(result).toEqual('')
    })

    // Tests that getDirnameMaxDepth returns the correct dirname with a relative path that contains both forward and backward slashes
    it('test_relative_path_with_slashes', () => {
      const relativePath = 'path/to\file'
      const expectedOutput = 'path'
      const actualOutput = getDirnameMaxDepth({relativePath})
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that getDirnameMaxDepth returns the correct dirname for a relative path that contains special characters
    it('test_special_characters', () => {
      const relativePath =
        'path/with/special/characters/!@#$%^&*()_+{}|:<>?[];,./'
      const expectedDirname = 'path/with/special/characters'
      const actualDirname = getDirnameMaxDepth({relativePath})
      expect(actualDirname).toEqual(expectedDirname)
    })
  })

  describe('getDirname_function', () => {
    // Tests that the function returns the correct dirname for a valid path
    it('test valid path', () => {
      expect(getDirname('/path/to/file')).toEqual('/path/to')
    })

    // Tests that the function returns the correct dirname for a valid Windows UNC root path
    it('test windows unc root path', () => {
      mockedPlatform('win32')
      expect(getDirname('\\helloworld')).toEqual('.')
    })

    // Tests that the function returns the correct dirname for a path with a trailing slash
    it('test path with trailing slash', () => {
      expect(getDirname('/path/to/file/')).toEqual('/path/to')
    })

    // Tests that the function returns the correct dirname for a Windows UNC root path with a trailing slash
    it('test windows unc root path with trailing slash', () => {
      mockedPlatform('win32')
      expect(getDirname('\\hello\\world\\')).toEqual('.')
    })

    // Tests that the function returns the correct dirname for a path with multiple slashes
    it('test path with multiple slashes', () => {
      expect(getDirname('/path//to/file')).toEqual('/path/to')
    })

    // Tests that the function returns the correct dirname for a Windows UNC root path with multiple slashes
    it('test windows unc root path with multiple slashes', () => {
      mockedPlatform('win32')
      expect(getDirname('\\hello\\world')).toEqual('.')
    })
  })

  describe('normalizeSeparators_function', () => {
    // Tests that forward slashes are normalized on Linux
    it('test forward slashes linux', () => {
      const input = 'path/to/file'
      const expectedOutput = 'path/to/file'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that backslashes are normalized on Windows
    it('test backslashes windows', () => {
      mockedPlatform('win32')
      const input = 'path\\to\\file'
      const expectedOutput = 'path\\to\\file'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that forward slashes are normalized on Windows
    it('test mixed slashes windows', () => {
      mockedPlatform('win32')
      const input = 'path/to/file'
      const expectedOutput = 'path\\to\\file'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that mixed slashes are normalized on Windows
    it('test mixed slashes windows', () => {
      mockedPlatform('win32')
      const input = 'path\\to/file'
      const expectedOutput = 'path\\to\\file'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that an empty string returns an empty string
    it('test empty string', () => {
      const input = ''
      const expectedOutput = ''
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that multiple consecutive slashes are removed
    it('test multiple consecutive slashes', () => {
      const input = 'path//to//file'
      const expectedOutput = 'path/to/file'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that UNC format is preserved on Windows
    it('test unc format windows', () => {
      mockedPlatform('win32')
      const input = '\\\\hello\\world'
      const expectedOutput = '\\\\hello\\world'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })

    // Tests that a drive root is preserved on Windows
    it('test drive root windows', () => {
      mockedPlatform('win32')
      const input = 'C:\\'
      const expectedOutput = 'C:\\'
      const actualOutput = normalizeSeparators(input)
      expect(actualOutput).toEqual(expectedOutput)
    })
  })

  describe('getFilteredChangedFiles', () => {
    // Tests that the function returns an empty object when allDiffFiles and filePatterns are empty
    it('should return an empty object when allDiffFiles and filePatterns are empty', async () => {
      const result = await getFilteredChangedFiles({
        allDiffFiles: {
          [ChangeTypeEnum.Added]: [],
          [ChangeTypeEnum.Copied]: [],
          [ChangeTypeEnum.Deleted]: [],
          [ChangeTypeEnum.Modified]: [],
          [ChangeTypeEnum.Renamed]: [],
          [ChangeTypeEnum.TypeChanged]: [],
          [ChangeTypeEnum.Unmerged]: [],
          [ChangeTypeEnum.Unknown]: []
        },
        filePatterns: []
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: [],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function returns allDiffFiles when filePatterns is empty
    it('should return allDiffFiles when filePatterns is empty', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: ['file1.txt'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: []
      })
      expect(result).toEqual(allDiffFiles)
    })

    // Tests that the function returns an empty object when allDiffFiles is empty
    it('should return an empty object when allDiffFiles is empty', async () => {
      const result = await getFilteredChangedFiles({
        allDiffFiles: {
          [ChangeTypeEnum.Added]: [],
          [ChangeTypeEnum.Copied]: [],
          [ChangeTypeEnum.Deleted]: [],
          [ChangeTypeEnum.Modified]: [],
          [ChangeTypeEnum.Renamed]: [],
          [ChangeTypeEnum.TypeChanged]: [],
          [ChangeTypeEnum.Unmerged]: [],
          [ChangeTypeEnum.Unknown]: []
        },
        filePatterns: ['*.txt']
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: [],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function returns only the files that match the file patterns on non windows platforms
    it('should return only the files that match the file patterns', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: [
          'file1.txt',
          'file2.md',
          'file3.txt',
          'test/dir/file4.txt',
          'test/dir/file5.txt',
          'dir/file6.md'
        ],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: ['*.txt']
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: ['file1.txt', 'file3.txt'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function returns only the files that match the file patterns on windows
    it('should return only the files that match the file patterns on windows', async () => {
      mockedPlatform('win32')
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: [
          'file1.txt',
          'file2.md',
          'file3.txt',
          'test\\dir\\file4.txt',
          'test\\dir\\file5.txt',
          'dir\\file6.md'
        ],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: ['*.txt']
      })

      expect(result).toEqual({
        [ChangeTypeEnum.Added]: ['file1.txt', 'file3.txt'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function returns only the files that match the file patterns with globstar on non windows platforms
    it('should return only the files that match the file patterns with globstar', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: [
          'file1.txt',
          'file2.md',
          'file3.txt',
          'test/dir/file4.txt',
          'test/dir/file5.txt',
          'dir/file6.md'
        ],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: ['**.txt']
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: [
          'file1.txt',
          'file3.txt',
          'test/dir/file4.txt',
          'test/dir/file5.txt'
        ],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function returns only the files that match the file patterns with globstar on windows
    it('should return only the files that match the file patterns with globstar on windows', async () => {
      mockedPlatform('win32')
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: ['test\\test rename-1.txt'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: ['test/**']
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: ['test\\test rename-1.txt'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function returns an empty object when there are no files that match the file patterns
    it('should return an empty object when there are no files that match the file patterns', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: ['file1.md', 'file2.md', 'file3.md'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: ['*.txt']
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: [],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that the function can handle file names with special characters
    it('should handle file names with special characters', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: [
          'file1.txt',
          'file2 with spaces.txt',
          'file3$$.txt'
        ],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const result = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns: ['file2*.txt']
      })
      expect(result).toEqual({
        [ChangeTypeEnum.Added]: ['file2 with spaces.txt'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      })
    })

    // Tests that getFilteredChangedFiles correctly filters files using glob patterns
    it('should filter files using glob patterns', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: ['test/migrations/test.sql'],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const filePatterns = ['test/migrations/**']
      const filteredFiles = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns
      })
      expect(filteredFiles[ChangeTypeEnum.Added]).toEqual([
        'test/migrations/test.sql'
      ])
    })

    // Tests that getFilteredChangedFiles correctly filters files using ignore glob patterns
    it('should filter files using ignore glob patterns', async () => {
      const allDiffFiles = {
        [ChangeTypeEnum.Added]: [],
        [ChangeTypeEnum.Copied]: [],
        [ChangeTypeEnum.Deleted]: [],
        [ChangeTypeEnum.Modified]: [
          'assets/scripts/configure-minikube-linux.sh'
        ],
        [ChangeTypeEnum.Renamed]: [],
        [ChangeTypeEnum.TypeChanged]: [],
        [ChangeTypeEnum.Unmerged]: [],
        [ChangeTypeEnum.Unknown]: []
      }
      const filePatterns = [
        'assets/scripts/**.sh',
        '!assets/scripts/configure-minikube-linux.sh'
      ]
      const filteredFiles = await getFilteredChangedFiles({
        allDiffFiles,
        filePatterns
      })
      expect(filteredFiles[ChangeTypeEnum.Modified]).toEqual([])
    })
  })

  describe('warnUnsupportedRESTAPIInputs', () => {
    // Warns about unsupported inputs when using the REST API.
    it('should warn about unsupported inputs when all inputs are supported', async () => {
      const inputs: Inputs = {
        files: '',
        filesSeparator: '\n',
        filesFromSourceFile: '',
        filesFromSourceFileSeparator: '\n',
        filesYaml: '',
        filesYamlFromSourceFile: '',
        filesYamlFromSourceFileSeparator: '\n',
        filesIgnore: '',
        filesIgnoreSeparator: '\n',
        filesIgnoreFromSourceFile: '',
        filesIgnoreFromSourceFileSeparator: '\n',
        filesIgnoreYaml: '',
        filesIgnoreYamlFromSourceFile: '',
        filesIgnoreYamlFromSourceFileSeparator: '\n',
        separator: ' ',
        includeAllOldNewRenamedFiles: false,
        oldNewSeparator: ',',
        oldNewFilesSeparator: ' ',
        sha: '1313123',
        baseSha: '',
        since: '',
        until: '',
        path: '.',
        quotepath: true,
        diffRelative: true,
        dirNames: false,
        dirNamesMaxDepth: undefined,
        dirNamesExcludeCurrentDir: false,
        dirNamesIncludeFiles: '',
        dirNamesIncludeFilesSeparator: '\n',
        dirNamesDeletedFilesIncludeOnlyDeletedDirs: false,
        json: false,
        escapeJson: true,
        safeOutput: true,
        fetchDepth: 50,
        fetchAdditionalSubmoduleHistory: false,
        sinceLastRemoteCommit: false,
        writeOutputFiles: false,
        outputDir: '.github/outputs',
        outputRenamedFilesAsDeletedAndAdded: false,
        recoverDeletedFiles: false,
        recoverDeletedFilesToDestination: '',
        recoverFiles: '',
        recoverFilesSeparator: '\n',
        recoverFilesIgnore: '',
        recoverFilesIgnoreSeparator: '\n',
        token: '${{ github.token }}',
        apiUrl: '${{ github.api_url }}',
        skipInitialFetch: false,
        failOnInitialDiffError: false,
        failOnSubmoduleDiffError: false,
        negationPatternsFirst: false,
        useRestApi: false,
        excludeSubmodules: false,
        fetchMissingHistoryMaxRetries: 20,
        usePosixPathSeparator: false,
        tagsPattern: '*',
        tagsIgnorePattern: ''
      }

      const coreWarningSpy = jest.spyOn(core, 'warning')

      await warnUnsupportedRESTAPIInputs({
        inputs
      })

      expect(coreWarningSpy).toHaveBeenCalledWith(
        'Input "sha" is not supported when using GitHub\'s REST API to get changed files'
      )

      expect(coreWarningSpy).toHaveBeenCalledTimes(1)
    })
  })
  describe('getPreviousGitTag', () => {
    // Check if the environment variable GITHUB_REPOSITORY_OWNER is 'tj-actions'
    const shouldSkip = !!process.env.GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FORK
    // Function returns the second-latest tag and its SHA
    it('should return the second latest tag and its SHA when multiple tags are present', async () => {
      if (shouldSkip) {
        return
      }
      const result = await getPreviousGitTag({
        cwd: '.',
        tagsPattern: '*',
        tagsIgnorePattern: '',
        currentBranch: 'v1.0.1'
      })
      expect(result).toEqual({
        tag: 'v1.0.0',
        sha: 'f0751de6af436d4e79016e2041cf6400e0833653'
      })
    })
    // Tags are filtered by a specified pattern when 'tagsPattern' is provided
    it('should filter tags by the specified pattern', async () => {
      if (shouldSkip) {
        return
      }
      const result = await getPreviousGitTag({
        cwd: '.',
        tagsPattern: 'v1.*',
        tagsIgnorePattern: '',
        currentBranch: 'v1.0.1'
      })
      expect(result).toEqual({
        tag: 'v1.0.0',
        sha: 'f0751de6af436d4e79016e2041cf6400e0833653'
      })
    })
    // Tags are excluded by a specified ignore pattern when 'tagsIgnorePattern' is provided
    it('should exclude tags by the specified ignore pattern', async () => {
      if (shouldSkip) {
        return
      }
      const result = await getPreviousGitTag({
        cwd: '.',
        tagsPattern: '*',
        tagsIgnorePattern: 'v0.*.*',
        currentBranch: 'v1.0.1'
      })
      expect(result).toEqual({
        tag: 'v1.0.0',
        sha: 'f0751de6af436d4e79016e2041cf6400e0833653'
      })
    })

    // No tags are available in the repository
    it('should return empty values when no tags are available in the repository', async () => {
      jest.spyOn(exec, 'getExecOutput').mockResolvedValueOnce({
        stdout: '',
        stderr: '',
        exitCode: 0
      })
      const result = await getPreviousGitTag({
        cwd: '.',
        tagsPattern: '*',
        tagsIgnorePattern: '',
        currentBranch: ''
      })
      expect(result).toEqual({tag: '', sha: ''})
    })

    // Only one tag is available, making it impossible to find a previous tag
    it('should return empty values when only one tag is available', async () => {
      jest.spyOn(exec, 'getExecOutput').mockResolvedValueOnce({
        stdout:
          'v1.0.1|f0751de6af436d4e79016e2041cf6400e0833653|2021-01-01T00:00:00Z',
        stderr: '',
        exitCode: 0
      })
      const result = await getPreviousGitTag({
        cwd: '.',
        tagsPattern: '*',
        tagsIgnorePattern: '',
        currentBranch: 'v1.0.1'
      })
      expect(result).toEqual({tag: '', sha: ''})
    })

    // Git commands fail and throw errors
    it('should throw an error when git commands fail', async () => {
      jest
        .spyOn(exec, 'getExecOutput')
        .mockRejectedValue(new Error('git command failed'))
      await expect(
        getPreviousGitTag({
          cwd: '.',
          tagsPattern: '*',
          tagsIgnorePattern: '',
          currentBranch: 'v1.0.1'
        })
      ).rejects.toThrow('git command failed')
    })
  })
})
