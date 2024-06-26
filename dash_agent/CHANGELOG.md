## 0.4.0

* **Github Data Object Update**: Updated github object to allow extraction of only code, issues, or both. When defining `Github` object via `WebDataObject.fromGithub`, you can pass list of `GithubExtract` enums containing all the intended data types that you want to be extracted and index. For example, passing `[GithubExtract.code, GithubExtract.issues]` will index both code and issues.
* **Deep Crawling Web Page Support**: Added support for deep crawling the website to extract sites data without the need of providing explicit sitemap. You can use `WebDataObject.fromWebPage` along with base url of the website that you want to index. Additionally, you will also need to pass `performDeepCrawl` to `true` to enable deep crawling. By default the value is `false`, which means it will only index the shared url page only 

## 0.3.0

* **Github Data Object Support**: Added support to extract Github repo data conviniently. You can use `WebDataObject.fromGithub` for indexing a specific repo code and issues now.
* **Commandless Mode Support**: Added Commandless mode which is active by default when an agent is activated. Now you can interact with agent more naturally by chatting.
* **Metadata**: Added support to provide agent avatar and human readable display name. As an agent creator you can also set tags for agents that will help better visibilty for agents in the agent marketplace as well as devs to understand for what purposes or framework the agent can be used.

## 0.2.1

* **Updated README**: Fixed broken images in README

## 0.2.0

* **WorkspaceQueryStep Improvement**: Added `workspace_object_type` parameter to WorkpaceQeuryStep
* **Updated README**: The README has been updated to add section of **Testing Your Agents**.

## 0.1.1

* Fixed type cast error for `PromptQueryStep.dashOutputs`
* README update

## 0.1.0

* `SystemDataObject` dropped for `FileDataObject`
*  README update
*  End token implementation to convey dash_cli the end of json

## 0.0.1

* Initial Release
