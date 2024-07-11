import { authStore, HdNav } from '@itcast/basic';
import { bundleManager, common, ConfigurationConstant, Want } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { promptAction, router } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { ThemeDialog } from '../components/ThemeDialog';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';

export interface Tool {
  icon?: ResourceStr
  name: string
  value?: string
  onClick?: () => void,
  radius?: 0 | 1 | 2
}

@Component
export struct SettingsComp {
  @StorageProp('appColorMode')
  appColorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  @State
  version: string = ''
  @State
  cache: string = ''

  aboutToAppear(): void {
    this.getVersion()
  }

  getVersion() {
    bundleManager.getBundleInfoForSelf(
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA
    )
      .then((res) => {
        this.version = 'v' + res.versionName
      })
  }

  calcCache() {
    storageStatistics.getCurrentBundleStats()
      .then(res => {
        this.cache = (res.cacheSize / (1000 * 1000)).toFixed(2) + 'MB'
      })
  }

  clearCache() {
    const ctx = getContext()
    const ctxCacheDir = ctx.cacheDir
    const ctxExist = fileIo.accessSync(ctxCacheDir)
    if (ctxExist) {
      fileIo.rmdirSync(ctxCacheDir)
    }
    const app = ctx.getApplicationContext()
    const appCacheDir = app.cacheDir
    const appExist = fileIo.accessSync(appCacheDir)
    if (appExist) {
      fileIo.rmdirSync(appCacheDir)
    }
    promptAction.showToast({ message: '清理完毕' })
    this.calcCache()
  }

  dialog = new CustomDialogController({
    builder: ThemeDialog()
  })

  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      if (tool.icon) {
        Image(tool.icon)
          .width(16)
          .aspectRatio(1)
          .margin({ right: 12 })
      }
      Text(tool.name)
        .fontSize(16)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ right: 10 })
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(18)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .padding({ left: 16, right: 10 })
    .borderRadius({
      topLeft: tool.radius === 1 ? 8 : 0,
      topRight: tool.radius === 1 ? 8 : 0,
      bottomLeft: tool.radius === 2 ? 8 : 0,
      bottomRight: tool.radius === 2 ? 8 : 0
    })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }

  build() {
    Column() {
      HdNav({ title: '设置', showRightIcon: false, hasBorder: true })
      Column({ space: 0.5 }) {
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '编辑资料', radius: 1, onClick: () => {
            authStore.checkAuth({
              url: 'pages/ProfileEditPage'
            })
          }
        })
        this.toolsBuilder({ name: '账号设置', radius: 2 })
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '消息推送', radius: 1, onClick: () => {
            let want: Want = {
              bundleName: 'com.huawei.hmos.settings',
              abilityName: 'com.huawei.hmos.settings.MainAbility',
              uri: 'application_info_entry',
              parameters: {
                pushParams: 'com.itcast.pass_interview'
              }
            };
            const context = getContext(this) as common.UIAbilityContext
            context.startAbility(want)
          }
        })
        this.toolsBuilder({
          name: '深色模式',
          value: this.appColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '已开启' : '已关闭',
          radius: 1,
          onClick: () => {
            this.dialog.open()
          }
        })
        this.toolsBuilder({
          name: '清除应用缓存', value: this.cache, onClick: () => {
            this.clearCache()
          }
        })
        this.toolsBuilder({ name: '当前版本', value: this.version, radius: 2 })
        Blank()
          .height(15)
        Text('退出账号')
          .height(50)
          .fontColor($r('app.color.common_main_color'))
          .opacity(0.6)
          .onClick(async () => {
            await authStore.delUser()
            emitter.emit({ eventId: 100401 })
            router.back()
          })
      }
      .layoutWeight(1)
      .padding({ right: 15, left: 15 })
      .backgroundColor($r('app.color.common_gray_bg'))
    }
    .onVisibleAreaChange([0, 1], (isVisible) => {
      if (isVisible) {
        this.calcCache()
      }
    })
  }
}