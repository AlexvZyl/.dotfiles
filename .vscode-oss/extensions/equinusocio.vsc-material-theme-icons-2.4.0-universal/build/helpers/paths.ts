
export const PATHS = {
  icons: './out/icons',
  variants: './out/variants',
  tmpPathIcons: './out/variants/.material-theme-icons.tmp',
  pathIcons: './out/variants/Material-Theme-Icons.json',
  pathIconKey: (key: string): string => `./out/variants/Material-Theme-Icons-${key}.json`,
  src: './src',
  srcPartials: './src/icons/partials',
  srcSvgs: './src/icons/svgs',
  srcIconsTheme: './src/icons/icons-theme.mustache'
};
