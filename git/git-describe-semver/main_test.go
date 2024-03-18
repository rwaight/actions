package main

import (
	"testing"
	"github.com/rwaight/actions/git/git-describe-semver/cmd"
	//"git-describe-semver/cmd"
)

//var cmdExecutor cmd.Executor

type mockCmdExecutor struct{}

func (m *mockCmdExecutor) Execute(fv cmd.FullVersion) error {
    // Implement your mock logic here
    return nil
}

func TestMain(t *testing.T) {
    //testVersion := main("1.2.3")
	//testVersion := main()
	// // Replace cmdExecutor with a mock
    // cmdExecutor = &mockCmdExecutor{}
    // defer func() {
    //     cmdExecutor = cmd.Execute // Restore the original cmdExecutor
    // }()

    // // Run your main function
    // main()

    // // You can add assertions or checks here as needed
}
