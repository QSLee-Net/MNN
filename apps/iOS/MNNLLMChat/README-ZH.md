# MNNLLM iOS Application

## 介绍

本项目是一个基于MNN引擎，支持本地大模型多模态对话的iOS应用。

纯本地运行，隐私性强。当模型下载到本地之后，所有的对话都将在本地进行，不会有任何网络上传处理。

## 功能：

1. 本地模型
    - 本地已下载模式展示
    - 支持自定义置顶
2. 模型市场
    - 获取 MNN 支持的模型列表
    - 模型管理，支持下载和删除模型
        - 支持切换 Hugging Face、 ModelScope 和 Modeler 下载源
    - 模型搜索，支持关键词搜索、标签搜索
3. 基准测试
    - 支持自动化基准测试，输出Prefill speed、 Decode Speed 和 Memory Usage等信息
4. 多模态聊天对话：支持完整的Markdown格式输出
    - 文本到文本
    - 语音到文本
    - 图片到文本，图片可以拍摄输入或从图库中选择
5. 模型配置
    - 支持配置 mmap
    - 支持配置 sampling strategy
    - 支持配置 diffusion 设置
6. 对话历史
    - 支持模型对话历史列表，还原历史对话场景

### 视频介绍

<img width="200" alt="image" src="./assets/introduction.gif" />

[点击这里下载原分辨率介绍视频](https://github.com/Yogayu/MNN/blob/master/project/MNNLLMForiOS/assets/introduction.mov)

### 应用预览图

|  |  |  | |
|--|--|--|--|
| **Text To Text**  | **Image To Text**  | **Audio To Text**  | **Model Fliter** |
| ![Text To Text](./assets/text.PNG) | ![Image To Text](./assets/image.PNG) | ![Audio To Text](./assets/audio.jpg) | ![Audio To Text](./assets/fliter.PNG) |
| **Local Model** | **Model Market** | **Benckmark** | **History** |
| ![Model List](./assets/localModel.PNG) | ![History](./assets/modelMarket.PNG) | ![History](./assets/benchmark.jpeg) | ![History](./assets/history2.PNG) |


<p></p>

此外，本应用支持 DeepSeek  带think模式端侧使用：

<img src="./assets/deepseek.jpg" alt="deepThink" width="200" />


## 如何构建并使用

1. 下载仓库代码：

    ```shell
    git clone https://github.com/alibaba/MNN.git
    ```

2. 编译 MNN.framework:

    ```shell
    cd MNN/
    sh package_scripts/ios/buildiOS.sh "-DMNN_ARM82=true -DMNN_LOW_MEMORY=true -DMNN_SUPPORT_TRANSFORMER_FUSE=true -DMNN_BUILD_LLM=true -DMNN_CPU_WEIGHT_DEQUANT_GEMM=true
    -DMNN_METAL=ON
    -DMNN_BUILD_DIFFUSION=ON
    -DMNN_BUILD_OPENCV=ON
    -DMNN_IMGCODECS=ON
    -DMNN_OPENCL=OFF
    -DMNN_SEP_BUILD=OFF
    -DMNN_SUPPORT_TRANSFORMER_FUSE=ON"
    ```

3. 拷贝 framework 到 iOS 项目中

    ```shell
    mv MNN-iOS-CPU-GPU/Static/MNN.framework apps/iOS/MNNLLMChat
    ```

    确保 Link Binary With Libraried 中包含 MNN.framework，和其他三个 Framework。

    <img src="./assets/framework.png" alt="deepThink" width="400" />

    如果没有包含，可以手动添加 MNN.framework:

    <img src="./assets/addFramework.png" alt="deepThink" width="200" />
    <img src="./assets/addFramework2.png" alt="deepThink" width="200" />


4. 修改 iOS 签名并编译项目

    ```shell
    cd apps/iOS/MNNLLMChat
    open MNNLLMiOS.xcodeproj
    ```

    在 Xcode 项目属性中 Signing & Capabilities > Team 输入自己的账号和Bundle Identifier

    ![signing](./assets/signing.png)


    等待 Swift Package 下载完成之后，进行编译使用。

## 注意

iPhone 因为内存有限，建议使用7B以及以下的模型，避免内存不足导致的崩溃。


## 本地调试

本地调试模型非常简单，只需要将模型文件拖动到LocalModel文件夹下，然后运行项目即可：

1. 首先在 [huggingface](https://huggingface.co/taobao-mnn) 或者 [modelscope](https://modelscope.cn/organization/MNN) 下载 MNN 相关的模型

    <img width="400" alt="image" src="./assets/copyLocalModel.png" />

2. 将下载之后的模型文件夹内的所有文件，拖动到项目中 LocalModel 文件夹下：

    <img width="200" alt="image" src="./assets/copyLocalModel2.png" />

3. 确保以上文件都已经在 copy bundle resources 中

    <img width="400" alt="image" src="./assets/copyLocalMode3.png" />

4. 运行项目，点击进入聊天对话页面，进行模型对话和调试。

应用会自动检测并加载LocalModel文件夹中的模型，无需额外配置。


## Release Notes

### Version 0.4

- 新增项目三个大模块：本地模型，模型市场和基准测试 
- 新增基准测试，可以测试不同模型效果 
- 新增设置页面，可以从历史侧边蓝进入 
- 新增Ali CDN获取模型列表 
- 新增模型市场筛选功能

### Version 0.3.1

- 支持模型参数配置

| <img width="200" alt="image" src="./assets/SamplingStrategy1.PNG" /> | <img width="200" alt="image" src="./assets/SamplingStrategy2.PNG" /> | <img width="200" alt="image" src="./assets/SamplingStrategy3.PNG" /> ｜

### Version 0.3

新增：

- 支持 Modeler 源进行下载
- 支持 Stable Diffusion 文生图

| <img width="200" alt="image" src="./assets/diffusion.JPG" /> | <img width="200" alt="image" src="./assets/diffusionSettings.PNG" /> |

### Version 0.2 

新增：

- 支持配置mmap和手动缓存清理

- 支持使用 ModelScope 源进行模型下载

| <img width="200" alt="image" src="./assets/usemmap.PNG" /> | <img width="200" alt="image" src="./assets/downloadSource.PNG" /> |



## 引用

- [Exyte/Chat](https://github.com/exyte/Chat)
- [stephencelis/CSQLite](https://github.com/stephencelis/SQLite.swift)
- [swift-transformers](https://github.com/huggingface/swift-transformers/)