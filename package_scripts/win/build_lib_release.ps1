# MNN
#  |-- include
#  |-- lib
#       |-- Release
#             |--- Dynamic
#             |      |--- MD
#             |      |--- MT
#             |
#             |--- Static
#                    |--- MD
#                    |--- MT
#
Param(
    [Parameter(Mandatory=$true)][String]$path,
    [String]$backends,
    [Switch]$x86,
    [Switch]$cibuild,
    [Switch]$internalbuild
)

$erroractionpreference = "stop"
New-Item -Path $path -ItemType Directory -ErrorAction Ignore
$PACKAGE_PATH = $(Resolve-Path $path).Path
$PACKAGE_LIB_PATH = "$PACKAGE_PATH/lib/$(If ($x86) {"x86"} Else {"x64"})"
Remove-Item -Path $PACKAGE_LIB_PATH -Recurse -ErrorAction Ignore
mkdir -p $PACKAGE_LIB_PATH

#clear and create package directory
powershell ./schema/generate.ps1

if ($cibuild) {
    pushd $PACKAGE_LIB_PATH
    mkdir -p Release\Dynamic\MT
} else {
    Remove-Item -Path $PACKAGE_PATH/include -Recurse -ErrorAction Ignore
    cp -r include $PACKAGE_PATH
    cp -r tools/cv/include/cv $PACKAGE_PATH/include
    pushd $PACKAGE_LIB_PATH
    mkdir -p Release\Dynamic\MT, Release\Dynamic\MD, Release\Static\MD, Release\Static\MT
}
popd

$CMAKE_ARGS = "-DMNN_SEP_BUILD=OFF -DMNN_BUILD_TRAIN=ON -DMNN_BUILD_OPENCV=ON -DMNN_IMGCODECS=ON  -DMNN_OPENCL=ON -DMNN_VULKAN=ON -DMNN_AVX512=ON -DMNN_LOW_MEMORY=ON -DLLM_SUPPORT_VISION=true -DMNN_BUILD_LLM=ON -DMNN_SUPPORT_TRANSFORMER_FUSE=true -DLLM_SUPPORT_AUDIO=true -DMNN_BUILD_AUDIO=true"
$ONLY_DYNAMIC_MT = $False

if ($backends -ne $null) {
    Foreach ($backend in $backends.Split(",")) {
        if ($backend -eq "cuda") {
            $CMAKE_ARGS = "$CMAKE_ARGS -DMNN_CUDA=ON"
            $ONLY_DYNAMIC_MT = $True
        }
    }
}

if ($internalbuild) {
    $CMAKE_ARGS = "$CMAKE_ARGS -DMNN_INTERNAL=ON"
}

Remove-Item build -Recurse -ErrorAction Ignore
mkdir build
pushd build

function log([String]$msg) {
    echo "================================"
    echo "Build MNN (CPU $backends) $msg"
    echo "================================"
}

# build it according to cmake_cmd, exit 1 when any error occur
function Build([String]$cmake_cmd, [String]$ninja_cmd = "ninja MNN") {
    Invoke-Expression $cmake_cmd
    # build process may failed because of lnk1181, but be success when run again
    $try_times = 2
    if ($LastExitCode -eq 0) {
        For ($cnt = 0; $cnt -lt $try_times; $cnt++) {
            try {
                Invoke-Expression $ninja_cmd
                if ($LastExitCode -eq 0) {
                    return
                }
            } catch {}
        }
    }
    popd
    exit 1
}


##### Release/Dynamic/MT ####
log "Release/Dynamic/MT"
Remove-Item CMakeCache.txt -ErrorAction Ignore
Build "cmake -G Ninja $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DMNN_WIN_RUNTIME_MT=ON .."
cp MNN.lib, MNN.dll, MNN.pdb $PACKAGE_LIB_PATH\Release\Dynamic\MT
rm MNN.*

# cibuild just build single type for build test
if ($cibuild) {
    popd
    return
}

if ($ONLY_DYNAMIC_MT -eq $False) {
    ##### Release/Dynamic/MD ####
    log "Release/Dynamic/MD"
    Remove-Item CMakeCache.txt -ErrorAction Ignore
    Build "cmake -G Ninja $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DMNN_WIN_RUNTIME_MT=OFF .."
    cp MNN.lib, MNN.dll, MNN.pdb $PACKAGE_LIB_PATH\Release\Dynamic\MD
    rm MNN.*

    ##### Release/Static/MT ####
    log "Release/Static/MT"
    Remove-Item CMakeCache.txt -ErrorAction Ignore
    Build "cmake -G Ninja $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DMNN_WIN_RUNTIME_MT=ON -DMNN_BUILD_SHARED_LIBS=OFF .."
    cp MNN.lib $PACKAGE_LIB_PATH\Release\Static\MT

    ##### Release/Static/MD ####
    log "Release/Static/MD"
    Remove-Item CMakeCache.txt -ErrorAction Ignore
    Build "cmake -G Ninja $CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DMNN_WIN_RUNTIME_MT=OFF -DMNN_BUILD_SHARED_LIBS=OFF .."
    cp MNN.lib $PACKAGE_LIB_PATH\Release\Static\MD
}
popd
