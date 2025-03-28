# mitechcon

This is the demo environment from my presentation at MITechCon 2025.  It is provided as a reference.  If you have questions, let me know.

>[!IMPORTANT]
>It is important to note that what I have include here will not work out of the box.  I did change some values like the repository names.  If you want to actually use this stuff you will need to >go through it with a fine tooth comb and modify things to meet your needs.  I am simply providing this as a reference for you to reverse engineer.

# Tool list

One of my main goals was to share the tools we had used build our new pipelines so that others can take that list like building blocks and build their own solutions.  I was asked if I had a blog post or something with the list of tools that we had used.  This is my effort to create that list.  I believe this is a complete list of tools and technologies that was used to build our CI/CD pipelines.  I would be more then happy to answer any questions.

-  Github templates
	- Used to setup new repositories by collecting reference configuration files in one place.  We used this github action to sync changes between these templates and their child repos, including initial setup.
		- AndreasAugustin/actions-template-sync@v2
- customizer.py
	- This is a simple python script I wrote that takes templated files from our template repositories and customizes them for use with child repositories.  When setting up a repo for the first time we just modify values in custimze.yaml and run this script as part of ```make init``` to set everything up.  This allows us to push changes to the templates with the sync workflow while not overwriting the customized version in the each repository.
- pre-commit
	- Use to setup and manage our pre-commit and pre-push hooks.
	- https://pre-commit.com/
- Makefile
	- The Makefile in the repo is the actually the core of our CI  pipeline.
	- We have standardized our Makefile directives while allowing for customization  between projects
- Semver
	- We have our developers install semver globally.  It's used by Makefile to calculate new versions but locally and in our github actions.  We can control the type of bump via the STEP variable in the Makefile.  We use the get-ver directive in our Makefile to get the version breakdown when needed.
	- https://www.npmjs.com/package/semver
- Crane
	- This tool is used to manipulate our containers and artifacts.  In our Makefile we use crane to annotate and tag containers in our repository including the version annotation.  The Makefile uses crane to later get the version annotation of the latest container and along with JQ it feeds that into semver when calculating new versions.
	- https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md
- hadolint
	- Linter we use to drive dockerfile best practices across our repositoriesI .
	- https://github.com/hadolint/hadolint
- trivy
	- We scan using trivy with a pre-push hook.  Our container repository, Harbor, also uses trivy for scanning.  We scan for vulnerabilities, misconfiguration, and secrets.
	- https://trivy.dev/latest/
- github actions
	- We have three standard github actions for each of our repositories.
		- 1. linting: This workflow runs our linters to validate that they had passed before being commited and pushed.  This workflow runs on
			- pull_request types:[opened, reopened, synchronize, ready_for_review]
			- branches: [main, master, develop]
		- 2. build: First runs our Unittests.  Then runs ```make build``` to build and push the new artifact.  It also uses ```make get-ver``` to calculate the version for that artifact while filling in the STEP variable based on pull request labels.  This workflow runs when the pull_request is closed but only if it was also merged and the skip-build label isn't present on the PR.
		- 3. adhoc build: A slightly modified version of our build worflow that runs when manually triggered against any branch.
- Harbor
	- This is our new artifact repository.  It is a private repository that we host in our management cluster.  It allows us to scan artifacts with trivy when they are pushed into the repo, set availability rules based on those scan results, cache containers from other repositories, backup and replicated our containers, and more.
	- https://goharbor.io/
- ArgoCD
	- We use ArgoCD to maintain our K8s clusters using a gitops approach.  We have a single repository in which we maintain our different clusters using an app-in-app approach.  Because of this, when we want to deploy new versions we just need to commit their tags to this repo and then ArgoCD will handle the deployment when it next syncs.
	- We create ArgoCD applications to install each stage of our applications using custom written helm charts with their own value files.  It is important to note that we have to have a separate ArgoCD app for each stage of an application (dev, qa, staging, prod).  These applications are built and maintained via ArgoCD itself.
	- https://argo-cd.readthedocs.io/en/stable/
- Kargo
	- Kargo is essentially the UI for our CD pipeline.  It scans container and helmchart repositories and combines them into freight that can be  promoted to each stage of the CD pipeline.  It also triggers validation checks when we promote to QA.
	- https://kargo.io/
- kargo-helpers
	- This is a small, in-house developed flask application that we wrote to handle functionality we wanted that Kargo doesn't help support.  Primarily this includes the creation and merging of our Deployment PRs.  After successfully promoting to QA, kargo uses its http step to POST to kargo-helpers API which in turn creates a release branch and deployment PR on the projects github repo to merge changes from develop to main.  We also use the http step when promoting to production to merge that branch.
	- In the future we will used kargo-helper to help support our hotfix workflow including back merging changes to the develop branch when needed.
- Testkube
	- Testkube is our testing framework.  We are writing  functionality tests that will be run after successfully promoting to QA.  This will start the test that is configured in Testkube and wait for it to successfully finish.  Our QA testers can then go into Testkube as needed to look at the results of those tests, review created artifacts, and re-run tests as needed.
	- https://testkube.io/
- Playwright
	- We are writing our end-to-end functionality tests using playwright
	- https://playwright.dev/

