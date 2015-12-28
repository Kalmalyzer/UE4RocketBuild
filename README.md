# Build Unreal Engine 4 from source to a distributable package

## About

This repository contains in-progress instructions on how to create a "Launcher" / "Rocket" build from Epic's GitHub repository.

So far it can successfully build a version of the engine. I have not tested building a stand-alone game executable using this engine version yet. Distribution and installation of a new engine version is still not sorted.

UE 4.10.0 is currently being used when testing.

## Usage

1. Grab the UE4 project from GitHub.

2. Apply the contents of this repository on top.

3. Run Setup.bat.

4. Build a local version of the engine: `Engine\Build\BatchFiles\RunUAT.bat gubp -Node=GatherRocket -TargetPlatforms=Win64 -NoSign`

5. The resulting build will appear in LocalBuilds\Rocket.

6. TODO: figure out how to distribute and "install" this on developers' machines.

See below for more usage instructions.


## Background

Epic offers two ways for developers to use UE4:

You can download a pre-built binary package (aka "Launcher" or "Rocket" builds) via the Epic Games Launcher. This allows you to develop games using UE4, as long as you only create content and change code inside of the game module or create plugins. This approach is not appropriate if you need to do any kind of engine modifications.

Epic also offers the UE4 sourcecode via their GitHub repository (https://www.github.com/EpicGames). The most straightforward workflow here is to have both the engine source code and the game source code in the same repository. This allows you to do any engine modifications that you like. However, this also leads to each single developer building the engine themselves locally. It is possible to submit pre-built binaries to version control, but there is no definite workflow documented.

Some developers would like a flow where a single developer builds a "Rocket"-style build of the engine, and then every other developer installs the "Rocket"-style engine build. The goal of this repository is to reach that point.

## Why is it hard for us to do a Rocket build?

Rocket builds are not documented by Epic. It is not a feature that is officially supported by them.

When Epic do their Rocket builds, they are not building from the public GitHub repository; they build off of an internal repository, which contains more files than the public GitHub repository. Most of the reasons for Rocket build pipeline breaks is due to either the build system relying on certain files (which are not in the GitHub repository) to exist or the build system relying on certain environment configurations which are not part of the source code and only exist on Epic's build servers and workstations.

## References

This forum thread has provided most of the information so far:
(https://forums.unrealengine.com/showthread.php?69744-Distributing-custom-build-to-team)

## Important things encountered so far

### Making the "promotable" code paths in UnrealBuildTool run

UnrealBuildTool needs to see at least one code project with the IsPromotable flag set. If not, the GUBP build process will fail very early on with an error message about a key missing in a dictionary. The BlankCodeProject has been created solely for that purpose.
This is a clean replacement for the two code changes which <> describes in the forum thread linked above.

Reference: LegacyBranchSetup.cs, search for "DoASharedPromotable" and "NumSharedAllHosts".
Reference: BlankCodeProjectEditor.Target.cs, search for "bIsPromotable".

### Giving the Engine project a path on disk

Internally, UnrealBuildTool creates a fake UProject which represents the engine itself. That project does not have any path on-disk. UnrealBuildTool will pick up the location of BlankProject, and apply it to the engine project.
(Not certain whether this makes any difference -- I suspect that this blank project can be removed without any adverse consequences)

### Executable signing

One of the "Rocket" build steps is to sign all executables with Epic Games' digital signature. Epic will not distribute that certificate. The certificate owner's name is hardcoded into the build pipeline sourcecode. The signing step can be ignored by providing `-NoSign` on the command line.

Reference: CommandUtils.cs, search for "SigningIdentity" and "SignTool"

### Making samples and templates visible to the build pipeline

The build pipeline has references to the starter content and template projects, but the GitHub project's .uprojectdirs file does not make those projects visible to the build pipeline. This results in errors when building Rocket builds. The SamplesAndTemplates.uproject file makes those projects visible to the build pipeline.
It appears that skipping building of these projects would require changes to the build system - it's possible to skip building of the DerivedDataCache directoy by supplying "-NoDDC" on the commandline, but later steps are then likely to fail anyway. There are hardcoded lists with the project names in several places.

Reference: SamplesAndTemplates.uproject

Reference: RocketBuild.Automation.cs, search for "CurrentTemplates" and "CurrentFeaturePacks"

## Commandline options for RunUAT

### Incremental builds

If you specify `-ForceIncrementalCompile` on the command line then those build steps which default to doing clean builds will also do incremental builds. This is particularly useful if you are getting a build error during C++ compilation, and want to re-run the build pipeline without recompiling all C++ code over again. Note that a build which has been produced with this switch is not guaranteed to be correct (if it was, then the build pipeline would default to incremental behaviour).

### Specifying multiple platforms when building

You can list multiple platforms like so: `-TargetPlatforms=Win32+Win64`

Reference: UEBuildTarget.cs, search for "UnrealTargetPlatform"

### Further commandline options

Most commandline options that apply are listed at the beginning of GUBP.cs.

## Future research

Look in UnrealVersionselector.cpp, RegisterCurrentEngineDirectory(). What should the engine registration mechanism look like for a manually-built engine version?
