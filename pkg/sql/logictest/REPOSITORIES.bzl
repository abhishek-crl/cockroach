# DO NOT EDIT THIS FILE MANUALLY! Use `release update-releases-file`.
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

CONFIG_LINUX_AMD64 = "linux-amd64"
CONFIG_LINUX_ARM64 = "linux-arm64"
CONFIG_DARWIN_AMD64 = "darwin-10.9-amd64"
CONFIG_DARWIN_ARM64 = "darwin-11.0-arm64"

_CONFIGS = [
    ("23.2.5", [
        (CONFIG_DARWIN_AMD64, "df4126568c3bded296d61e4fba5ee14f0ac3029dff25ba82d55c5580d04f5408"),
        (CONFIG_DARWIN_ARM64, "1f213ef13a565bf0e4f5cab0b957fcb34584c4561a46f1af014bd4dc2d8449c1"),
        (CONFIG_LINUX_AMD64, "f8c21f6ed2aee6fc57a60799ef5fbed477d820522106c225a1da705524478403"),
        (CONFIG_LINUX_ARM64, "4d7fb3165697c2d03ab0020d8fc62e2a82b6cd2dda91840074f3fafed36b2789"),
    ]),
    ("24.1.0-rc.2", [
        (CONFIG_DARWIN_AMD64, "a0dd50ff29b83c211330240d7d321fe99b9019a96fbb83e648e9172bf861cd8f"),
        (CONFIG_DARWIN_ARM64, "3c3e54fbd7effb5e7ffa1dc664710a4975a2734b8a6cd6adb0a4bd189c628d30"),
        (CONFIG_LINUX_AMD64, "6ebfc44dfbae91396a4087884afcad3b63178dc98ec7f85dfbc52ad6ad334303"),
        (CONFIG_LINUX_ARM64, "9570a17138d0f896f70e8ee59d1d0c3ba50f7d648e3fe23830a0af3302925d7c"),
    ]),
]

def _munge_name(s):
    return s.replace("-", "_").replace(".", "_")

def _repo_name(version, config_name):
    return "cockroach_binary_v{}_{}".format(
        _munge_name(version),
        _munge_name(config_name))

def _file_name(version, config_name):
    return "cockroach-v{}.{}/cockroach".format(
        version, config_name)

def target(config_name):
    targets = []
    for versionAndConfigs in _CONFIGS:
        version, _ = versionAndConfigs
        targets.append("@{}//:{}".format(_repo_name(version, config_name),
                                         _file_name(version, config_name)))
    return targets

def cockroach_binaries_for_testing():
    for versionAndConfigs in _CONFIGS:
        version, configs = versionAndConfigs
        for config in configs:
            config_name, shasum = config
            file_name = _file_name(version, config_name)
            http_archive(
                name = _repo_name(version, config_name),
                build_file_content = """exports_files(["{}"])""".format(file_name),
                sha256 = shasum,
                urls = [
                    "https://binaries.cockroachdb.com/{}".format(
                        file_name.removesuffix("/cockroach")) + ".tgz",
                ],
            )
