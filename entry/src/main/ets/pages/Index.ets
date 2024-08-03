import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { preferences } from '@kit.ArkData';
let options: preferences.Options = { name: 'myStore' };
let dataPreferences: preferences.Preferences = preferences.getPreferencesSync(getContext(), options);

interface Cat{
  id: string,
  url: string,
  width: number,
  height: number,
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  controller: TabsController = new TabsController();
  @State cats: Cat[] = []
  @State savecats: Cat[] = []
  aboutToAppear(): void {
    let httpRequest = http.createHttp();
    httpRequest.request(
      'https://api.thecatapi.com/v1/images/search?limit=10',
      (err, data)=>{
        if(!err){
          this.cats = JSON.parse(data.result.toString())
        }
      })
  }
  @Builder LabelImage(label: string, targetIndex: number, selectedImg: Resource, normalImg: Resource){
    Column(){
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 30, height: 30 } )
      Text(label)
        .fontColor(this.currentIndex === targetIndex ? '#1296db' : '#2c2c2c')
    }
    .width('100%')
    .onClick(() => {
      this.currentIndex = targetIndex
      this.controller.changeIndex(this.currentIndex)
    })
  }
  build() {
    Column(){
      Tabs({controller: this.controller}){

        // 下面是“首页”页面
        TabContent(){
          Column(){
            Text('Cat you like !')
            List(){
              ForEach(this.cats, (item: Cat) => {
                ListItem(){
                  Column(){
                    Image(item.url).borderRadius({
                      topLeft: 10,
                      topRight: 10,
                    })
                    Row (){
                      Text("id:" + `${ item.id}`).margin({ left: 10})
                      Text(`${item.width} * ${item.height}`).margin({ left: 10})
                      Text('收藏').margin({  right: 15 })
                        .onClick(()=>{
                          let dataPreferences: preferences.Preferences | null = preferences.getPreferencesSync(getContext(), options);
                          console.log('Data Preferences:', dataPreferences);

                          let value: string = dataPreferences.getSync('cats', '[]').toString();
                          let cats: Cat[] = JSON.parse(value)
                          cats.push(item)
                          dataPreferences.putSync('cats', JSON.stringify(cats))
                          dataPreferences.flush()
                          promptAction.showToast({
                            message: '收藏成功',
                          })
                        })
                    }
                    .width('100%')
                    .height(30)
                    .margin({ top: 20, left: 10, right: 10})
                    .justifyContent(FlexAlign.SpaceBetween)
                  }
                  .borderRadius(10)
                  .margin({ top: 20, bottom: 20 })
                  .shadow({
                    radius: 10,
                    color: ('#cdcdcd'),
                    // offsetX: 10,
                    offsetY: 10
                  })
                }
              },(item: Cat)=> {
                return item.id
              })
            }
            .width('100%')
            .height('100%')
          }
          .width('96%')
          .height('100%')
        }.tabBar(this.LabelImage('首页', 0, $r("app.media.home_selected"), $r('app.media.home_normal')))

        // 下面是“我的”页面
        TabContent(){
          Column(){
            List(){
              ForEach(this.savecats, (item: Cat) => {
                ListItem(){
                  Column(){
                    Image(item.url).borderRadius({
                      topLeft: 10,
                      topRight: 10,
                    })
                    Row (){
                      Text("id:" + `${ item.id}`).margin({ left: 10})
                      Text(`${item.width} * ${item.height}`).margin({ left: 10})
                      Text('删除').margin({  right: 15 })
                    }
                    .width('100%')
                    .height(30)
                    .margin({ top: 20, left: 10, right: 10})
                    .justifyContent(FlexAlign.SpaceBetween)
                  }
                  .borderRadius(10)
                  .margin({ top: 20, bottom: 20 })
                  .shadow({
                    radius: 10,
                    color: ('#cdcdcd'),
                    offsetY: 10
                  })
                }
              },(item: Cat)=> {
                return item.id
              })
            }
            .width('100%')
            .height('100%')
          }
        }
        .tabBar(this.LabelImage('My', 1, $r("app.media.user_selected"), $r('app.media.user_normal')))
        .onWillShow(() => {
          console.log('onWillShow')
          let value: string = dataPreferences.getSync('cats', '[]').toString();
          this.savecats = JSON.parse(value)
        })
      }
      .barPosition(BarPosition.End)
    }
    .height('100%')
    .width('100%')
  }
}