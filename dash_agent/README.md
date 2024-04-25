# Dash Agent 

Dash agent is a framework enabling you to create and publish agents in CommandDash marketplace. 

## Getting started

Install the package in your dart project:

```bash
flutter pub add dash_agent
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  dash_agent: ^1.0.0
```

**Note**: Ideally, you won't need to install the package into your dart project. Since, you will be creating the agent project using [dash-cli]()'s `dash-cli create {{agent}}` command line tool. This will install the package for you.


## Usage

This package contain the building blocks for creating dash agents:

### AgentConfiguration

The main part of the framework that glues together your agent configuration is `AgentConfiguration`. It is the base class for creating agent.

Sample example of `AgentConfiguration` for demonstration purpose:

```dart
class MyAgent extends AgentConfiguration {
  final docsSource = DocsDataSource();

  @override
  List<DataSource> get registeredDataSources => [docsSource];

  @override
  List<Command> get registerSupportedCommands =>
      [AskCommand(docsSource: docsSource)];
}
```

The above sample AgentConfiguration object taking data sources and supported commands. Both of them are explained below:

- `DataSource`: Data sources will enable you to pass on any form of data that your agent might need to perform its intended tasks.
- `Command`: Commands are the specialised tasks you want your agents to perform. They can be anything like understanding the developer query and providing the desired response, evaluating the project workspace, updating a piece of code based on the user requirement and the type of agent, or even generate code as per the developer requirement.

### Datasource

As described above data sources lets you attach the data that your agent will need to perform its tasks. It can be anything from raw texts, json, files data, or even webpages.

Sample example for DataSource for demostration purpose:

```dart
class DocsDataSource extends DataSource {
 @override
 List<SystemDataObject> get fileObjects => [
       SystemDataObject.fromFile(File(
           'your_file_path'))
     ];

 @override
 List<ProjectDataObject> get projectObjects =>
     [ProjectDataObject.fromText('Data in form of raw text')];

 @override
 List<WebDataObject> get webObjects => [];
}

class BlogsDataSource extends DataSource {
 @override
 List<SystemDataObject> get fileObjects => [
       DirectoryFiles(
           Directory(
               'directory_path_to_data_source'),
           relativeTo:
               'parent_directory_path')
     ];

 @override
 List<ProjectDataObject> get projectObjects => [];

 @override
 List<WebDataObject> get webObjects =>
     [WebDataObject.fromWebPage('https://sampleurl.com')];
}
```

As visible in the above example, the data is divided into:

- Project Data (aka `ProjectDataObject`): This data object enables you to pass in raw string and json data.
- System Data  (aka `SystemDataObject`): This data object enables you to pass data stored in files and directories in you local system,
- Web Data (aka `WebDataObject`): This data object enables you to pass web data your agent by passing web pages urls or sitemaps in the object.

To create any data object, the easiest (and also the recommended way) is to call static functions of the above shared bases class of the object. For example if you want to store the json data. You can add the json data as shared below:

```dart
final yourJson = {'key': 'data'};
final jsonDataSource = ProjectDataSource.fromJson(yourJson);
```

**Note**: At the moment, storing pdf files is not supported out of the box. However you can extract the relevant data from the pdf using the open source tools and pass the extracted data either via project data object or system data object

### Commands

Commands are the specialised tasks you want your agents to perform  (such as refactoring, code generation, code analysis, etc). Once the agent will be published, user's can invoke this command in the commanddash client (such as VS Code extensions) and use them. 

Sample example for `Command` object is shared below:

```dart
class AskCommand extends Command {
  AskCommand({required this.docsSource});

  final DataSource docsSource;

  // Inputs
  final userQuery = StringInput('Your query');
  final codeAttachment = CodeInput('Code Attachment');

 // Outputs
 final matchingDocuments = MatchDocumentObject();
 final queryOutput = QueryOutput();

  @override
  String get slug => '/ask';

  @override
  String get intent => 'Ask me anything';

  @override
  List<DashInput> get registerInputs => [userQuery, codeAttachment];

  @override
  List<Step> get steps => [
        MatchingDocumentStep(
            query: '$userQuery$codeAttachment',
            dataSources: [docsSource],
            output: matchingDocuments),
        PromptQueryStep(
            prompt:
                '''You are an X agent. Here is the $userQuery, here is the document references: $matchingDocuments. Answer the user's query.''',
            postProcessKind: PostProcessKind.raw,
            output: queryOutput),
        AppendToChatStep(
            value:
                'This was your query: $userQuery and here is your output: $queryOutput'),
      ];

  @override
  String get textFieldLayout =>
      "Hi, I'm here to help you. $userQuery $codeAttachment";
}
```

`Command` object takes the following properties:
- `slug` - Unique identifier of the command
- `intent` - Brief description about the command
- `textFieldLayout` - Phrase that will be shown to user when the command is
invoked
- `registerInputs` - `DashInput`s that will be used in the command in its
lifecycle
- `steps` - Series of operation that needs to be performed for a command finish its
task. Steps can be of the following nature: Matching docs that are shared
with the command, performing a query in the user project, prompt that code/
info generation, appending the info/code at the right place in the project,
many more.

One of important element of `Command` object are the series of steps that you will be passing that will help the command to execute its tasks by performing the mini-tasks required to be performed by the main task.


### Step

Currently supported steps that are avaiable for you leverage are shared below:

- `MatchDocumentStep` - Helps you find the matching document from the provided data source form `DataSource` objects.
- `WorkspaceQueryStep` - Helps you find the matching code snippets from the user's project.
- `PromptQueryStep` - Enables you to perform a request to the lllm model with your customised prompt and instruction from the user to perform get generated code or any other general reponse that can be either used for next steps or passed back to the user as the final response.
- `AppendToChatStep` - Enables you to append the reponse (anything like code, feedback, or general reponse) to the commanddash client chat box.
- `ReplaceCodeStep` - This is experimental at the moment. This step will enable you to directly replace the user's selected code with the resulting output code from the command.
- `ContinueDecisionStep` - This is also experimental at the moment. This step will help you in adding a conditional logic in your series of steps. While calling this step, if it outputs `false`. Then the further execution of steps will stop and command is considered executed.

In future more steps will be included in the list as the framework evolves.

## Additional information

We welcome the flutter and AI enthusiasts likewise to contribute to this amazing open source framework. You can contribute this framework in following ways:

-  **File feature requests**: Suggest features that'll make your development process easier in the [issues board](https://github.com/CommandDash/packages/issues).

-  **Pick up open issues**: Pick up and fix existing issues open to the community in [issues board](https://github.com/CommandDash/packages/issues).

-  **Participate in discussions**: Help by sharing your ideas in the [active discussions](https://join.slack.com/t/welltested-ai/shared_invite/zt-25u09fty8-gaggH9HbmopB~4tialTrlA) in our community slack.


## Community

Connect with like minded people building with Flutter and using AI to do so, every step of the way :D [Join Now](https://join.slack.com/t/welltested-ai/shared_invite/zt-25u09fty8-gaggH9HbmopB~4tialTrlA)