# Chirpy Starter

[![Gem Version](https://img.shields.io/gem/v/jekyll-theme-chirpy)][gem]&nbsp;
[![GitHub license](https://img.shields.io/github/license/cotes2020/chirpy-starter.svg?color=blue)][mit]

When installing the [**Chirpy**][chirpy] theme through [RubyGems.org][gem], Jekyll can only read files in the folders
`_data`, `_layouts`, `_includes`, `_sass` and `assets`, as well as a small part of options of the `_config.yml` file
from the theme's gem. If you have ever installed this theme gem, you can use the command
`bundle info --path jekyll-theme-chirpy` to locate these files.

The Jekyll team claims that this is to leave the ball in the user’s court, but this also results in users not being
able to enjoy the out-of-the-box experience when using feature-rich themes.

To fully use all the features of **Chirpy**, you need to copy the other critical files from the theme's gem to your
Jekyll site. The following is a list of targets:

```shell
.
├── _config.yml
├── _plugins
├── _tabs
└── index.html
```

To save you time, and also in case you lose some files while copying, we extract those files/configurations of the
latest version of the **Chirpy** theme and the [CD][CD] workflow to here, so that you can start writing in minutes.

## Usage

Check out the [theme's docs](https://github.com/cotes2020/jekyll-theme-chirpy/wiki).

## Upgrading Chirpy

This site follows the low-maintenance Chirpy Starter workflow:

- keep site content and configuration in this repository;
- keep the theme itself as the `jekyll-theme-chirpy` gem in `Gemfile`;
- keep `Gemfile.lock` ignored for now;
- pull Starter release changes from the `chirpy` upstream remote.

One-time setup for a fresh clone:

```shell
git remote add chirpy https://github.com/cotes2020/chirpy-starter.git
git config submodule.assets/lib.ignore all
```

If the `chirpy` remote already exists, skip the first command.

Upgrade to a new Chirpy release tag:

```shell
git fetch origin
git merge --ff-only origin/main
git fetch chirpy --tags
git merge vX.Y.Z --squash --allow-unrelated-histories
bundle update jekyll-theme-chirpy
bash tools/test.sh
```

Replace `vX.Y.Z` with the target Starter tag, for example `v7.5.0`.
Resolve conflicts by keeping local site identity/content in `_config.yml`,
`_data/contact.yml`, and `_tabs/about.md`, while taking upstream structural
changes in `Gemfile`, the GitHub Pages workflow, and other Starter-managed
files when appropriate. After the build passes, commit the resolved upgrade.

## Contributing

This repository is automatically updated with new releases from the theme repository. If you encounter any issues or want to contribute to its improvement, please visit the [theme repository][chirpy] to provide feedback.

## License

This work is published under [MIT][mit] License.

[gem]: https://rubygems.org/gems/jekyll-theme-chirpy
[chirpy]: https://github.com/cotes2020/jekyll-theme-chirpy/
[CD]: https://en.wikipedia.org/wiki/Continuous_deployment
[mit]: https://github.com/cotes2020/chirpy-starter/blob/master/LICENSE
