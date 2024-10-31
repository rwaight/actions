module.exports = {
    // This file is sourced from the 'infra' repo, the file location is: 'infra/assets/repo_root/commitlint.config.js'
    extends: [
        '@commitlint/config-conventional'
    ],
    /*
    * Ignore dependabot commit messages until https://github.com/dependabot/dependabot-core/issues/2445 is fixed.
    */
    ignores: [
        (msg) => /Signed-off-by: dependabot\[bot\]/m.test(msg),
        // // https://stackoverflow.com/questions/60194822/how-do-you-configure-commitlint-to-ignore-certain-commit-messages-such-as-any-th#60195181
        (message) => message.includes('WIP'),
        message => /\bWIP\b/i.test(message)
    ],

    rules: {
        // consider adding the 'body-case', 'body-max-line-length', and 'header-max-length' in the future
        // inspired by https://medium.com/neudesic-innovation/conventional-commits-a-better-way-78d6785c2e08
        // from https://gist.github.com/mfcollins3/cf30d28239752ffe9eb6009a0f0c8f33#file-commitlint-js-config
        //'body-case': [2, 'always', 'sentence-case'],
        //'body-max-line-length': [1, 'always', 72],
        //'header-max-length': [1, 'always', 52],
        'type-enum': [2, 'always', [
            // types are from https://github.com/commitizen/conventional-commit-types/blob/master/index.json
            // last updated from: https://github.com/commitizen/conventional-commit-types/blob/v3.0.0/index.json
            'feat',
            'fix',
            'docs',
            'style',
            'refactor',
            'perf',
            'test',
            'build',
            'ci',
            'chore',
            'revert',
            // the 'change', 'deprecate', 'remove', and 'security' types were added on 02APR2024, inspired by 
            // https://medium.com/neudesic-innovation/conventional-commits-a-better-way-78d6785c2e08
            'change',
            'deprecate',
            'remove',
            'security'
        ]]
    },

    helpUrl: 'https://github.com/conventional-changelog/commitlint/#what-is-commitlint'
    // helpUrl: 'https://github.com/conventional-changelog/commitlint/#what-is-commitlint'
};
