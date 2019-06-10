# cloudformation-templates
A collection of AWS cloudformation templates

## cicd

### sam-template.yml

Creates a CodePipeline containing the following stages:
  * Checkout
    * Checks out code from repository when changes are merged
  * Build
    * Performs a build using `buildspec.yml` from checked out code
  * Deploy
    * Creates a changeset using the `template.yml` from checked out code
    * Applies changeset creating/updating resources (i.e. API Gateway, Lambdas, etc)

**Creating Pipeline**

To create a pipeline for a git repository run the `create-sam-stack.sh` script. For example:

```bash
./create-sam-stack.sh aws-sam-ref-api slalom
```

This will create a build pipeline for <https://github.com/slalom/aws-sam-ref-api>
