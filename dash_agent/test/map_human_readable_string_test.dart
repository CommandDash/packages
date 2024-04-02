import 'package:dash_agent/extension/map_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pass a map convert it into a human readable string', () {
    final sampleMap = {
      "data_sources": [
        {
          "id": "851329594",
          "version": "0.0.1",
          "project_objects": [
            {
              "id": "277698105",
              "type": "text_object",
              "content": "Some Value",
              "version": "0.0.1"
            }
          ],
          "file_objects": [
            {
              "id": "1031754791",
              "type": "file_object",
              "content": "my-article.txt",
              "version": "0.0.1"
            }
          ],
          "web_objects": []
        },
        {
          "id": "927886482",
          "version": "0.0.1",
          "project_objects": [],
          "file_objects": [
            {
              "id": "236503663",
              "type": "directory_files",
              "files": [
                {"id": "236503663", "type": "file_object", "content": ""},
                {"id": "236503663", "type": "file_object", "content": ""}
              ],
              "version": "0.0.1"
            }
          ],
          "web_objects": [
            {
              "id": "567512344",
              "type": "web_page",
              "url": "https://pub.dev/packages/path",
              "version": "0.0.1"
            }
          ]
        }
      ],
      "supported_commands": [
        {
          "slug": "/ask",
          "intent": "Ask me anything",
          "text_field_layout":
              "Hi, I'm here to help you. <944736829> <695320325>",
          "registered_inputs": [
            {
              "id": "944736829",
              "display_text": "Your query",
              "type": "string_input",
              "version": "0.0.1"
            },
            {
              "id": "695320325",
              "display_text": "Code Attachment",
              "type": "code_input",
              "generateFullString": false,
              "version": "0.0.1"
            }
          ],
          "registered_outputs": [
            {
              "id": "168691877",
              "type": "match_docuement_output",
              "version": "0.0.1"
            },
            {
              "id": "595231091",
              "type": "multi_code_object",
              "version": "0.0.1"
            },
            {"id": "205645190", "type": "prompt_output", "version": "0.0.1"}
          ],
          "steps": [
            {
              "type": "search_in_sources",
              "query": "<944736829><695320325>",
              "data_sources": ["<851329594>"],
              "total_matching_document": 0,
              "output": "<168691877>",
              "version": "0.0.1"
            },
            {
              "type": "search_in_workspace",
              "query": "<168691877>",
              "workspace_object_type": "all",
              "output": "<595231091>",
              "version": "0.0.1"
            },
            {
              "type": "prompt_query",
              "prompt":
                  "You are an X agent. Here is the <944736829>, here is the <595231091> and the document references: <168691877>. Answer the user's query.",
              "post_process": {"type": "raw"},
              "output": "<205645190>",
              "version": "0.0.1"
            },
            {
              "type": "append_to_chat",
              "value":
                  "This was your query: <944736829> and here is your output: <205645190>",
              "version": "0.0.1"
            }
          ],
          "version": "0.0.1"
        }
      ],
      "version": "0.0.1",
      "cli_version": "0.0.1"
    };

    final mapString = sampleMap.humanReadableString();
    print(mapString);
  });
}
