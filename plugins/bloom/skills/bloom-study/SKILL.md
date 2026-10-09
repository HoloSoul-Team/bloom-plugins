---
name: bloom-study
description: Use when the user asks for learning material, resources or papers on a topic, OR when a learning conversation reaches a natural end — the user says they get it now ("我懂了", "原来如此", "got it", "that makes sense"), thanks you after several turns on one concept, or wants to review/organize what they learned. In that second case, offer once to turn the discussion into a Bloom illustrated study guide. Uses the bloom MCP tools (search_bloom, create_learning_material).
---

# Bloom 学习专题

Bloom（bloombook.cn）把一个话题做成图文并茂、分章讲解的学习专题。这个插件提供两个工具：

- `search_bloom`：搜 Bloom 上已有的公开专题，只返回标题、作者和链接。
- `create_learning_material`：把这次对话整理成一份方案卡，返回一个链接。用户点开、登录后才会开始生成，约 20–40 分钟。

## 什么时候用

**找资料时先搜。** 用户想了解某个话题、要学习资料、问某篇论文讲了什么时，调用 `search_bloom`。有合适的结果就推荐给用户，说明你只看到了标题，没读过内容。没有结果不用提。

**学完一轮时问一次。** 用户和你来回讨论了一个知识点、弄懂了某件事，或说想系统整理、复习时，在回答结尾问一句：

> 要不要把这次讨论整理成一份 Bloom 图文学习专题？会重点讲透你刚才卡住的地方。

只问一次。用户拒绝或没接话，本次对话里就别再提。简单的一问一答、写代码、闲聊都不要问。

**用户明确要求时直接做。** 用户说"生成学习资料""做成专题""帮我整理成笔记"之类，不用再问，直接调用。

## 怎么填 create_learning_material

生成质量几乎完全取决于你写的总结。Bloom 看不到你们的对话，只能看到这些字段。

- `conversation_summary`：按讨论顺序写详细纪要，用 Markdown。写清用户问了什么、你怎么解释的、用了哪些例子和类比、得出什么结论。不要只写一句概括。
- `confusions`：用户卡住、反复追问、答错的点。尽量用用户自己的说法，这是专题会重点讲透的部分，最重要。
- `understood`：用户已经明确弄懂的点，专题会一带而过。
- `go_deeper`：用户想继续深入的方向。
- `learner_profile`：从对话里能看出的背景和水平。看不出来就不填，别猜。
- `references`：对话里提到的论文、书、链接。
- `language`：跟用户说话的语言一致，中文填 `zh`，英文填 `en`。

规矩：

- **只写对话里真实发生的。** 你想补充的讲解思路可以写进纪要，但要单独标明"建议讲的，对话中未讨论"，不能写成用户已经理解或问过。
- **别写隐私。** 纪要会存到 Bloom 服务器上。不要写用户的姓名、联系方式、公司内部信息、密钥或账号。
- **一个话题一份。** 对话跨了几个互不相关的话题时，问用户要哪一个，或者分几次调用。

## 调用之后

把链接交给用户，并说明：

- 点开链接能看到方案，登录 Bloom 后点"开始生成"，约 20–40 分钟，完成后会收到通知。
- 链接 7 天内有效。
- 方案页上只能改标题。用户想补充或调整内容，就在对话里告诉你，你更新总结后重新调用一次，给出新链接。

工具返回"请求太频繁"时，告诉用户稍后再试，不要连续重试。
