package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestApplyNoError(t *testing.T) {
	t.Parallel()

	tests := []string{
		//"../examples/encryption",
		//"../examples/replications",
		//"../examples/diagnostic-settings",
		//"../examples/simple",
		"../examples/multiple",
	}

	for _, test := range tests {
		t.Run(test, func(t *testing.T) {
			terraformOptions := &terraform.Options{
				TerraformDir: test,
				NoColor:      true,
			}

			terraform.WithDefaultRetryableErrors(t, &terraform.Options{})

			defer terraform.Destroy(t, terraformOptions)
			terraform.InitAndApply(t, terraformOptions)
		})
	}
}
