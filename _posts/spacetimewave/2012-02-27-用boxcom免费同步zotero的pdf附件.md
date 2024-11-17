---
categories:
- 时空波动
date: '2012-02-27 11:20:24'
description: ''
tags:
- 科研软件
- zotero
- 学术
- 信息时代
title: 用box.com免费同步Zotero的pdf附件
---
Zotero提供了100MB的免费空间来同步你下载的文献的pdf文件。超过这个限制Zotero要收取一定的合理费用。如果你手头宽裕并且很依赖这个软件，建议考虑使用Zotero提供的收费同步服务。这样你可以从任何一台电脑登陆Zotero的网页版直接阅读到你下载的pdf文件，另外也给zotero一个稳定的收入来源，可以让开发者继续提供更好的服务。Zotero也提供了利用Webdav同步的选择，这样你可以申请一个免费提供Webdav的云储存提供商，例如下面介绍的box.com来同步你的文件。大致步骤如下：



\* 申请一个box.com帐户。
\* 在zotero的Preferences\-\>sync选项卡中选择用webdav来同步。然后使用这个网址：https://www.box.com/dav/zotero/ . (只需输入www.box.com/dav即可)
\* 点击Verify Server就完成了。

如果你发现这个错误：

”Your WebDAV server must be configured to serve files without extensions and files with .prop extensions in order to work with Zotero.”

可以试试[这个解决方法](https://forums.zotero.org/discussion/20351/your-webdav-server-must-be-configured-to-serve-files-without-extensions-and-files-with-prop-extensi/)：

“You can try going to about:config in the Firefox address bar (or clicking "Open about:config" from the Advanced pane of the preferences in Standalone) and setting extensions.zotero.sync.storage.verified to true. ”

