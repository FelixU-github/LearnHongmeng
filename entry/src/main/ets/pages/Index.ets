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
  @State saveCats: Cat[] = []
  @State visible: Visibility = Visibility.Hidden
  private swiperController: SwiperController = new SwiperController()
  // @State imageIndex :
  requestData(){
    let httpRequest = http.createHttp();
    httpRequest.request(
      'https://api.thecatapi.com/v1/images/search?limit=10',
      (err, data)=>{
        if(!err){
          let newCats: Cat[]= JSON.parse(data.result.toString())
          this.cats = [...this.cats, ...newCats]
        }
      })
  }
  aboutToAppear(): void {
    this.requestData()
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
          Stack() {
            Text('Choice the cat you like !'+ `${ this.cats.length}`)
            List(){
              ForEach(this.cats, (item: Cat) => {
                ListItem(){
                  Column(){
                    Image(item.url).borderRadius({
                      topLeft: 10,
                      topRight: 10,
                    }).width('90%')
                    Row (){
                      Text("id:" + `${ item.id}`).margin({ left: 10})
                      Text(`${item.width} * ${item.height}`).margin({ left: 10})
                      Text('收藏').margin({  right: 15 })
                        .onClick(()=>{
                          let dataPreferences: preferences.Preferences | null = preferences.getPreferencesSync(getContext(), options);
                          let value: string = dataPreferences.getSync('cats', '[]').toString();
                          let cats: Cat[] = JSON.parse(value)
                          if (cats.length >=20){
                            promptAction.showToast({message:'最多收藏20只猫 ！'})
                          }else {
                            let result = cats.some((value,) =>{
                              return value.id === item.id
                            })
                            if (result){
                              promptAction.showToast({message:'已收藏'})
                            }else{
                              cats.push(item)
                              dataPreferences.putSync('cats', JSON.stringify(cats))
                              dataPreferences.flush()
                              promptAction.showToast({
                                message: '收藏成功',
                              })
                            }
                          }
                        })
                    }
                    .width('94%')
                    .height(30)
                    .margin({ top: 20, left: 10, right: 10})
                    .justifyContent(FlexAlign.SpaceBetween)
                  }
                  .width('100%')
                  .borderRadius(10)
                  .margin({ top: 20, bottom: 20 })
                  .shadow({
                    radius: 10,
                    color: ('#cdcdcd'),
                    offsetX: 10,
                    offsetY: 10
                  })
                }
                .width('100%')
              },(item: Cat)=> {
                return item.id
              })
            }
            .width('100%')
            .height('100%')
            // .onReachStart(() =>{
            //   this.cats = []
            //   this.requestData()
            //   promptAction.showToast({message:'已加载'})
            // })
            // .onReachEnd(()=>{
            //   this.requestData()
            //   promptAction.showToast({message:'已加载更多'})
            // })
            Text('刷新')
              .onClick(()=>{
                this.cats = []
                this.requestData()
                promptAction.showToast({message: '已刷新'})
              })
              .width(50)
              .height(50)
              .backgroundColor(Color.Pink)
              .opacity(0.5)
              .textAlign(TextAlign.Center)
              .borderRadius(25)
              .position({ x: '80%', y: '70%' })
            Text('更多')
              .onClick(()=>{
                this.requestData()
                promptAction.showToast({message: '已加载更多'})
              })
              .width(50)
              .height(50)
              .backgroundColor('#db93e4')
              .opacity(0.5)
              .textAlign(TextAlign.Center)
              .borderRadius(25)
              .position({ x: '80%', y: '80%' })

            Swiper(this.swiperController) {
              ForEach(this.cats, (item: Cat) => {
                Image(item.url)
                  .width('90%')
                  .height(160)
                  .backgroundColor(0xAFEEEE)
                  .onClick(() => {
                    this.visible = Visibility.Hidden
                  })
                  // .textAlign(TextAlign.Center)
                  // .fontSize(30)
              }, (item: Cat) => item.id)
            }
            .visibility(this.visible)
            .cachedCount(2)
            .index(1)
            .autoPlay(true)
            .interval(4000)
            .indicator( // 设置圆点导航点样式
              new DotIndicator()
                .itemWidth(15)
                .itemHeight(15)
                .selectedItemWidth(15)
                .selectedItemHeight(15)
                .color(Color.Gray)
                .selectedColor(Color.Blue))
            .loop(true)
            .duration(1000)
            .itemSpace(0)
            .displayArrow(true, false)

          }
          .width('100%')
          .height('100%')
        }.tabBar(this.LabelImage('首页', 0, $r("app.media.home_selected"), $r('app.media.home_normal')))

        // 下面是“我的”页面
        TabContent(){
          Column(){
            Text('The cat you like !')
            List(){
              ForEach(this.saveCats, (item: Cat , index :number) => {
                ListItem(){
                  Column(){
                    Image(item.url).borderRadius({
                      topLeft: 10,
                      topRight: 10,
                    }).width('94%')
                    Row (){
                      Text("id:" + `${ item.id}`).margin({ left: 10})
                      Text(`${item.width} * ${item.height}`).margin({ left: 10})
                      Text('删除').margin({  right: 15 })
                        .onClick(()=>{
                          let value: string = dataPreferences.getSync('cats', '[]').toString();
                          let cats: Cat[] = JSON.parse(value)
                          cats.splice(index,1)
                          dataPreferences.putSync('cats', JSON.stringify(cats))
                          dataPreferences.flush()
                          this.saveCats = cats
                          promptAction.showToast({
                            message: '已删除',
                          })
                        })

                    }
                    .width('94%')
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
                }.width('100%')
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
          this.saveCats = JSON.parse(value)
        })
      }
      .barPosition(BarPosition.End)
    }
    .height('100%')
    .width('100%')
  }
}