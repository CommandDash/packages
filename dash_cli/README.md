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

To deploy the agent once you are finished logging in, please run the following command from the agent project directory:

```shell
dash_cli publish
```

This command fetches and validates your agent configuration. If validation is successful:
- The agent will be scheduled for creation.
- If validation fails, a warning will be issued indicating 'Failed to fetch agent configuration'. In such a case, please fix the agent configuration and attempt to publish again.

### 4. Logout from your dash_cli

To logout from your dash_cli. Simply run the following command:

```shell
dash_cli logout
```

## Additional information

We welcome the Flutter and AI enthusiasts likewise to contribute to this amazing open-source framework. You can contribute in the following ways:

- **File feature requests**: Suggest features that'll make your development process easier in the [issues board](https://github.com/CommandDash/packages/issues).

- **Pick up open issues**: Pick up and fix existing issues open to the community in [issues board](https://github.com/CommandDash/packages/issues).

- **Participate in discussions**: Help by sharing your ideas in the [active discussions](https://join.slack.com/t/welltested-ai/shared_invite/zt-25u09fty8-gaggH9HbmopB~4tialTrlA) in our community slack.


## Community

Connect with like-minded people building with Flutter and using AI to do so, every step of the way :D [Join Now](https://join.slack.com/t/welltested-ai/shared_invite/zt-25u09fty8-gaggH9HbmopB~4tialTrlA)