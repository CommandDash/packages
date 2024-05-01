# Dash CLI

Dash CLI is a command line tool that enables you to create, validate, and publish your agents at CommandDash marketplace. 


## Setup

### Install & Activate dash_cli

Install and activate the dash_cli globally via the pub activate command:

```shell
dart pub global activate dash_cli
```

## Quick Start

### 1. Create Agent Project

To create an agent configuration project, please run the following command in the directory where you want to create your project:

```shell
dash_cli create {{agent}}
```

Replace `{{agent}}` with the agent name that you wish to create. This will create the project with the same agent name.

### 2. Login to your dash_cli

After configuring your agent with commands and data sources, the subsequent step involves publishing it. To accomplish this, you must log in to dash_cli, which can be achieved by executing the following command:

```shell
dash_cli login
```

This command initiates the GitHub login flow, redirecting you to an authentication page. After completing authorization on the authentication page, you will have successfully logged in.

### 3. Deploy your Agent

When deploying the agent for the first time. You might want to try the agent from your end to ensure that the agent is working as expected. You can test it by deploying the agent in test mode. During this phase the agent will only be visible to you on the CommandDash extension. To deploy agent in test mode run the command command from the agent project directory:

```shell
dash_cli publish --test
```

This command fetches and validates your agent configuration. If validation is successful:
- The agent will be scheduled for creation.
- If validation fails, a warning will be issued indicating 'Failed to fetch agent configuration'. In such a case, please fix the agent configuration and attempt to publish again.

Upon the sucessful deployment you'll recieve the mail shared with CommandDash that your agent is ready for testing. Follow the instruction shared at the section [Test Your Agent](#5-test-your-agents) to test your deployed agents.


Once you satisfied with the agent performance and want to publish the agent for developer commmunity. You can simply do it by running the following command from the agent directory:

```shell
dash_cli publish
```

**Note**: You need to be logged in to dash_cli to deploy the agent

### 4. Logout from your dash_cli

To logout from your dash_cli. Simply run the following command:

```shell
dash_cli logout
```

### 5. Test Your Agents

Once the agent is deployed for testing via `dash_cli publish -t` command. You will be able to find your agent with **test** label in the **agent marketplace** of CommandDash as shown below:

[<img src="assets/test-agent-card.png"/>](assets/test-agent-card.png)

Click on the install button. And you should be able to test your newly created agent in the extension.

**Note**: You can navigate to the **agent marketplace** page in the CommandDash extension by clicking at the marketplace icon (encircled in the red square): 

[<img src="assets/marketplace-icon.png" width="500"/>](assets/marketplace-icon.png)

## Additional information

We welcome the Flutter and AI enthusiasts likewise to contribute to this amazing open-source framework. You can contribute in the following ways:

- **File feature requests**: Suggest features that'll make your development process easier in the [issues board](https://github.com/CommandDash/packages/issues).

- **Pick up open issues**: Pick up and fix existing issues open to the community in [issues board](https://github.com/CommandDash/packages/issues).

- **Participate in discussions**: Help by sharing your ideas in the [active discussions](https://join.slack.com/t/welltested-ai/shared_invite/zt-25u09fty8-gaggH9HbmopB~4tialTrlA) in our community slack.


## Community

Connect with like-minded people building with Flutter and using AI to do so, every step of the way :D [Join Now](https://join.slack.com/t/welltested-ai/shared_invite/zt-25u09fty8-gaggH9HbmopB~4tialTrlA)