// const agentJson = {
//   "inputs": [
//     {"id": "736841542", "type": "string_input", "value": ""},
//     {"id": "805088184", "type": "code_input", "value": "{chip-details}"}
//   ],
//   "outputs": [
//     {"id": "422243666", "type": "default_output"},
//     {"id": "436621806", "type": "multi_code_object"},
//     {"id": "90611917", "type": "default_output"}
//   ],
//   "authdetails": {
//     "type": "gemini" | "dash",
//     "key": "aisjoaisj",
//     "githubToken": "",
//   },
//   "steps": [
//     {
//       "type": "search_in_sources",
//       "query": "<736841542><805088184>",
//       "data_sources": ["<643643320>"],
//       "total_matching_document": 0,
//       "output": "<422243666>"
//     },
//     {
//       "type": "search_in_workspace",
//       "query": "<422243666>",
//       "workspace_object_type": "all",
//       "output": "<436621806>"
//     },
//     {
//       "type": "prompt_query",
//       "prompt":
//           "You are an X agent. Here is the <736841542>, here is the <436621806> and the document references: <422243666>. Answer the user's query.",
//       "post_process": {"type": "raw|code"},
//       "output": "<90611917>",
//     },
//     {
//       "type": "append_to_chat",
//       "value":
//           "This was your query: <736841542> and here is your output: <90611917>"
//     },
//     {
//       type: replace_code,
//     }
//   ]
// };
// // Request to edit file. Show diff view.