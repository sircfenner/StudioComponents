#!/usr/bin/env node

/*
adapted from: https://github.com/jsdotlua/dom-testing-library-lua/blob/main/scripts/npm-to-wally.js

changes:
- remove workspaces logic not required by this repository
- mirror description field from package.json to wally.toml

*/

const { Command } = require("commander");

const fs = require("fs").promises;
const path = require("path");
const process = require("process");

const extractPackageNameWhenScoped = (packageName) =>
    packageName.startsWith("@")
        ? packageName.substring(packageName.indexOf("/") + 1)
        : packageName;

const readPackageConfig = async (packagePath) => {
    const packageContent = await fs.readFile(packagePath).catch((err) => {
        console.error(
            `unable to read package.json at '${packagePath}': ${err}`
        );
        return null;
    });

    if (packageContent !== null) {
        try {
            const packageData = JSON.parse(packageContent);
            return packageData;
        } catch (error) {
            console.error(
                `unable to parse package.json at '${packagePath}': ${err}`
            );
        }
    }

    return null;
};

const main = async (
    packageJsonPath,
    wallyOutputPath,
    wallyRojoConfigPath,
    rojoConfigPath
) => {
    const packageData = await readPackageConfig(packageJsonPath);

    const {
        name: scopedName,
        version,
        license,
        dependencies = [],
        description,
    } = packageData;

    const tomlLines = ["[package]", `name = "${scopedName.substring(1)}"`];

    if (description) {
        tomlLines.push(`description = "${description}"`);
    }

    tomlLines.push(
        `version = "${version}"`,
        'registry = "https://github.com/UpliftGames/wally-index"',
        'realm = "shared"',
        `license = "${license}"`,
        "",
        "[dependencies]"
    );

    const rojoConfig = {
        name: "WallyPackage",
        tree: {
            $className: "Folder",
            Package: {
                $path: "src",
            },
        },
    };

    for (const [dependencyName, specifiedVersion] of Object.entries(
        dependencies
    )) {
        const name = extractPackageNameWhenScoped(dependencyName);
        rojoConfig.tree[name] = {
            $path: `${dependencyName}.luau`,
        };

        const wallyPackageName = name.indexOf("-") !== -1 ? `"${name}"` : name;
        if (specifiedVersion == "workspace:^") {
            error("workspace version not supported");
        } else {
            tomlLines.push(
                `${wallyPackageName} = "jsdotlua/${name}@${specifiedVersion}"`
            );
        }
    }

    tomlLines.push("");

    const wallyRojoConfig = {
        name: scopedName.substring(scopedName.indexOf("/") + 1),
        tree: {
            $path: "src",
        },
    };

    await Promise.all([
        fs.writeFile(wallyOutputPath, tomlLines.join("\n")).catch((err) => {
            console.error(
                `unable to write wally config at '${wallyOutputPath}': ${err}`
            );
        }),
        fs
            .writeFile(rojoConfigPath, JSON.stringify(rojoConfig, null, 2))
            .catch((err) => {
                console.error(
                    `unable to write rojo config at '${rojoConfigPath}': ${err}`
                );
            }),
        fs
            .writeFile(
                wallyRojoConfigPath,
                JSON.stringify(wallyRojoConfig, null, 2)
            )
            .catch((err) => {
                console.error(
                    `unable to write rojo config for wally at '${wallyRojoConfigPath}': ${err}`
                );
            }),
    ]);
};

const createCLI = () => {
    const program = new Command();

    program
        .name("npm-to-wally")
        .description("a utility to convert npm packages to wally packages")
        .argument("<package-json>")
        .argument("<wally-toml>")
        .argument("<wally-rojo-config>")
        .argument("<package-rojo-config>")
        .action(async (packageJson, wallyToml, wallyRojoConfig, rojoConfig) => {
            const cwd = process.cwd();
            await main(
                path.join(cwd, packageJson),
                path.join(cwd, wallyToml),
                path.join(cwd, wallyRojoConfig),
                path.join(cwd, rojoConfig)
            );
        });

    return (args) => {
        program.parse(args);
    };
};

const run = createCLI();

run(process.argv);
