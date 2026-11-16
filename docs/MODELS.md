# SolidWorks 建模资源使用教程

## 1. 选择正确下载项

前往 [models-2026-11-16 Release](https://github.com/s13753540656-sys/auto-car-pick-and-place-/releases/tag/models-2026-11-16)。下载：

- `auto-car-solidworks-models-2026-11-16.zip`：建模资料，约 41 MB。
- `auto-car-solidworks-models-2026-11-16.zip.sha256`：整个 ZIP 的校验值。

Release 自动生成的 `Source code (zip)` 和仓库的 `Code → Download ZIP` 是仓库快照，**不包含 Release 中的 CAD 压缩包**。只下载仓库还不能打开整车模型。

## 2. 文件内容

完整解压后得到：

```text
使用说明.txt
SHA256SUMS.txt
二队车newnew/
    校赛新新新整车.SLDASM
    整车.SLDASM
    夹爪三_总装配.SLDASM
    校赛轮组.SLDASM
    TOWER PRO MG-995, ANALOG SERVO.SLDASM
    ...40 个 SLDPRT 零件
    M2006_P36_实体版.STEP
```

文件总计为 46 个模型和 2 个说明 / 校验文件。逐个模型的名称、文件大小和哈希可在仓库 [MODEL_INDEX.json](../models/MODEL_INDEX.json) 查看；它是文件清单，不是装配引用图或采购 BOM。

## 3. 用 SolidWorks 打开

1. 将 ZIP **全部解压**到一个新目录，不在压缩软件内直接打开装配体。
2. 用兼容原始模型版本的 SolidWorks，浏览至 `二队车newnew` 文件夹。
3. 优先检查 `校赛新新新整车.SLDASM`；另有 `整车.SLDASM`。这两个名称来自原资料，哪一个是最终版本尚需设计者或本机打开确认，不以文件名或文件大小判定版本先后。
4. 只查看夹爪时可打开 `夹爪三_总装配.SLDASM`。零件与子装配文件保持在同一解压目录，不单独移动或重命名。
5. 打开后检查缺失 / 压缩组件、配置和配合错误，并记录软件版本及错误信息。

原始 SolidWorks 保存版本未确认。高版本文件在较低版本中的可用性受版本功能限制，不保证任意版本都能编辑。相关说明见 [SolidWorks 官方兼容性说明](https://blogs.solidworks.com/products/solidworks/solidworks-backwards-compatibility/)。

`M2006_P36_实体版.STEP` 只表示电机模型；当前包没有整车 STEP，不能用它替代装配体打开。

## 4. 出现缺失引用时

- 先确认完整解压了全部文件，而不是只取出 `.SLDASM`。
- 在 SolidWorks 中用 **File → Find References（查找引用）** 查看实际引用和失效项，逐项定位至本地解压目录。名称相同不代表引用关系已经正确。[官方查找引用说明](https://help.solidworks.com/2024/english/SolidWorks/sldworks/HIDD_FINDREFERENCES_HELP.htm?id=7.8.1.1)
- 暂不覆盖保存原文件；在副本中修正后，重新打开验证。
- 若缺失文件确实不在资源包中，记录装配名称、配置、缺失零件名及软件版本，通过 Issue 反馈，不用外形相近的零件直接替代。

完整打包时可在 SolidWorks 中使用 **Pack and Go** 汇总关联文件，并核对图纸、压缩零件和外部资源等选项。[官方 Pack and Go 说明](https://help.solidworks.com/2024/English/SolidWorks/Sldworks/c_pack_and_go.htm)

此 ZIP 是对现有目录的文件级整理，并非已经通过 SolidWorks Pack and Go 检查的发布；SHA-256 相同只能证明文件字节完整，不能证明不存在目录之外的引用。

## 5. 校验下载是否完整

Windows PowerShell 中先进入 ZIP 下载目录：

```powershell
Get-FileHash -LiteralPath .\auto-car-solidworks-models-2026-11-16.zip -Algorithm SHA256
Get-Content -LiteralPath .\auto-car-solidworks-models-2026-11-16.zip.sha256
```

对比两处哈希，忽略大小写。也可以使用本仓库脚本；以下命令在仓库根目录执行，将下载文件放入根目录或替换为真实路径：

```powershell
powershell -NoProfile -File .\scripts\Verify-ModelPackage.ps1 -ArchivePath .\auto-car-solidworks-models-2026-11-16.zip
```

脚本无需 SolidWorks，不会解压或修改模型；读取 ZIP 内的校验清单，逐项检查文件和哈希，并在旁边存在 `.sha256` 时核对整个包。看到 `Verification passed` 表示文件级校验通过，不表示机械或装配检查通过。若系统策略阻止脚本运行，可使用上面的 Get-FileHash 手工校验。

## 6. 常见问题

| 问题 | 处理 |
| --- | --- |
| 解压后没有模型 | 检查是不是下载了仓库 Source code，CAD 位于 Release 的命名附件中 |
| 打开报高版本 / Future Version | 检查当前软件版本；需兼容版本或经设计者确认的导出，不能靠改扩展名解决 |
| 零件丢失 | 完整解压、保持目录关系，再通过查找引用定位 |
| 不知道哪个是整车最终版 | 两个整车装配都保留；需本机检查或由设计者确认 |
| 能否直接生产或采购 | 目前没有完整 BOM、材料、公差和制造图，模型清单不能替代生产文件 |
| 有没有控制程序 | 当前没有 STM32 工程；模型无法代替固件或接线资料 |

原资料中的 `升降导轨.zip` 与这 46 个模型逐项哈希一致，属于重复打包，因此新包不再嵌套这份 ZIP。原始桌面目录未被修改。
