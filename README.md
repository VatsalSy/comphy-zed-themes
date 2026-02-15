# CoMPhy Crisp Themes for Zed Editor

A collection of high-contrast Zed themes optimized for clarity, readability, and visual comfort.

## Theme Variants

This extension currently ships four themes:

1. `CoMPhy Crisp Anysphere Blend Dark`
2. `CoMPhy Crisp Anysphere Blend Light`
3. `CoMPhy Crisp Anysphere (Highest Contrast, pop)`
4. `CoMPhy Crisp Highest Contrast`

## Installation

### From Zed's Extension Panel

1. Open Zed
2. Open the Extensions panel
3. Search for `CoMPhy Crisp Themes`
4. Click Install

### Manual Installation

1. Clone the repository: `git clone https://github.com/VatsalSy/comphy-zed-themes.git`
2. Open Zed
3. Open the Extensions panel
4. Click `Install Dev Extension`
5. Select the cloned repository directory

## Migration Notes

This rebrand updates names across the extension and repository:

- Extension package ID: `comphy-crisp-themes`
- Theme names: all variants now use the `CoMPhy Crisp` prefix
- Repository: `https://github.com/VatsalSy/comphy-zed-themes`

If you are upgrading from an older install, install `CoMPhy Crisp Themes` from the Extensions panel and re-select your preferred theme.

## Release Workflow

Releases are tag-driven:

- Workflow: `.github/workflows/release.yml`
- Trigger: push tags matching `v*`
- Publisher action: `huacnlee/zed-extension-action@v1.0.0`
- Extension name for publishing: `comphy-crisp-themes`

## Language Support

Enhanced syntax highlighting for:

- Python
- JavaScript and TypeScript
- Rust
- Go
- HTML and CSS
- JSON
- Markdown
- LaTeX
- Shell scripts
- And more

## License

MIT License. See `LICENSE`.
