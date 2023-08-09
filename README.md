This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/basic-features/font-optimization) to automatically optimize and load Inter, a custom Google Font.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.

## Tasks

### docker-build

```
docker build -t app-nodejs:main .
```

### docker-run

```
docker run -p 3000:3000 app-nodejs:main
```

### nix-build

```
nix build .#docker
podman load < result
```

### nix-run

```
podman run --rm -p 3000:3000 localhost/app:latest
```

### nix-copy

```
nix copy --derivation --to file://$PWD/export
nix copy --to file://$PWD/export #.default
nix copy --to file://$PWD/export #.docker
nix copy ---derivation -to file://$PWD/export #.docker
wget -O ./export/npmlock2nix.tar.gz https://github.com/nix-community/npmlock2nix/tarball/9197bbf397d76059a76310523d45df10d2e4ca81
tar -xzvf ./export/npmlock2nix.tar.gz -C ./export
rm ./export/npmlock2nix.tar.gz
mv ./export/nix-community-npmlock2nix-* ./export/npmlock2nix
```

Be careful when copying to ensure everything is copied: `cp -r ./export/* ~/nix-exports/app-nodejs/`

### nix-build-sandboxed

```
docker run -it --rm --network none -v `pwd`/export:/home/nix/export -v `pwd`:/nodejs-app nixpkgs-offline
```
