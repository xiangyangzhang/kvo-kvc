

#import "ViewController.h"
#import "AppModel.h"
#import "Student.h"

@interface ViewController ()
{
    AppModel *_model;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self kvcAppModel];
    //[self kvcStudent];
    
    //kvc 使用字典 赋值
    //[self kvcDict];
    
    [self kvoTest];
}
/*
 self.name = @"xiaohong";
 _name = @"xiaohong";
 
 1.第一个调用了setter方法 赋值
 2.第一个考虑了内存管理
 3. 第一个写法 可以被kvo 监听到
 
 */
//kvo ->键值监听
- (void)kvoTest {
    //kvo 键值观察者
    //监听 一个对象的属性 有没有 被setter方法 或者 kvc 进行修改
    NSArray *arr = @[@"setter方法修改属性",@"kvc修改属性",@"普通方法直接赋值修改属性",@"数组元素修改"];
    for (NSInteger i = 0; i < arr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10, 30+40*i, 300, 30);
        [button setTitle:arr[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 101+i;
        [self.view addSubview:button];
    }
    _model = [[AppModel alloc] init];
    //增加一个键值观察者
    
    /*
     NSKeyValueObservingOptionNew = 0x01,
     NSKeyValueObservingOptionOld = 0x02,
     */
    
    /*
     *增加一个观察者 监听 _model指向的对象的name 属性有没有调用 setter或者kvc
     第一个参数  观察者
       2       _model指向对象的属性路径
       3       能够监听到新值/旧值 并且能够得到
                NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 相或 表示 新旧值都可以得到
        4  一般写NULL 也可以传其他的 给观察者函数传值
     
     */
    
    [_model addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_model addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [_model addObserver:self forKeyPath:@"dataArr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    
}
#pragma mark - kvo监听到 之后 观察者调用的方法
//如果 观察者监听到 指定对象属性 被setter或kvc 修改了那么 就会调用

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    ///keyPath 就是 被监听的对象的属性路径
    // object  被监听的对象
    //change 就是监听到的 新值或者旧值
    if ([object isKindOfClass:[AppModel class]]) {
        NSLog(@"AppModel被kvo监听到调用setter或者kvc");
        if ([keyPath isEqualToString:@"name"]) {
            NSLog(@"change:%@",change);
            //监听到 name 属性 被setter或者kvc修改
            NSLog(@"name_old:%@",change[@"old"]);//旧值
            NSLog(@"name_new:%@",change[@"new"]);//新值
            //或者
            NSLog(@"name_old:%@",change[NSKeyValueChangeOldKey]);
            NSLog(@"name_new:%@",change[NSKeyValueChangeNewKey]);
        }else if([keyPath isEqualToString:@"dataArr"]) {
            NSLog(@"name_old:%@",change[NSKeyValueChangeOldKey]);
            NSLog(@"name_new:%@",change[NSKeyValueChangeNewKey]);
        }
    }
}


- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 101://Setter
        {
            _model.name = @"setter_xiaohong";
        }
            break;
        case 102://kvc
        {
            [_model setValue:@"kvc_xiaofen" forKeyPath:@"name"];
        }
            break;
        case 103://ChangeName
        {
            [_model changeName];//kvo 不能监听到
        }
            break;
        case 104://修改数组
        {
            [_model addObject:@"one"];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - kvc字典赋值
- (void)kvcDict {
    NSDictionary *dict = @{@"age":@(100),@"name":@"小红"};
    
    //同时对多个属性赋值
    AppModel *model = [[AppModel alloc] init];
    [model setValuesForKeysWithDictionary:dict];
    NSLog(@"name:%@",[model valueForKeyPath:@"name"]);
    
}

#pragma mark - kvc属性路径
- (void)kvcStudent {
    Student *stu = [[Student alloc] init];
    [stu setValue:@"1" forKeyPath:@"num"];
    AppModel *model = [[AppModel alloc] init];
    
#if 0
    
    [model setValue:@"10" forKeyPath:@"age"];
    [model setValue:@"xiaohong" forKeyPath:@"name"];
    [stu setValue:model forKeyPath:@"appModel"];
    NSLog(@"stu:%@",[stu valueForKeyPath:@"appModel"]);
#else
    //属性路径赋值
    [stu setValue:model forKeyPath:@"appModel"];
    //属性路径
    [stu setValue:@"10" forKeyPath:@"appModel.age"];
    [stu setValue:@"小红" forKeyPath:@"appModel.name"];
    
    AppModel *newModel = [stu valueForKeyPath:@"appModel"];
    NSLog(@"name:%@",[newModel valueForKeyPath:@"name"]);
    
#endif
    
    
}

#pragma mark - kvc
- (void)kvcAppModel {
    AppModel *model = [[AppModel alloc] init];
    
    //kvc赋值
    /*
    [model setValue:@(20) forKey:@"age"];
    [model setValue:@"小明" forKey:@"name"];
    */
    //kvc 赋值 方法2--》forKeyPath:后面可以写属性路径
    [model setValue:@(20) forKeyPath:@"age"];
    [model setValue:@"小红" forKeyPath:@"name"];
    /*
     kvc的赋值原理
     首先 调用kvc 赋值方法的首先 会去 AppModel类中找有没有-setName:这个setter方法(如果有那么就调用)，如果没有那么会去找有没有成员变量_name,有那么直接对_name赋值，如果没有那么就去找有没有叫name成员变量,如果有name 变量也是直接赋值 如果没有 程序崩溃
     
     为了防止崩溃要写出
     - (void)setValue:(id)value forUndefinedKey:(NSString *)key ；
     
          */
    
    [model setValue:@"123" forKeyPath:@"body"];
    
    NSLog(@"name:%@",[model funName]);
    
    //使用kvc 获取 对象属性的值
    NSString *name = [model valueForKeyPath:@"name"];
    /*
     kvc的  获取值 原理
     首先 调用kvc 获取值方法的首先 会去 AppModel类中找有没有-name这个getter方法(如果有那么就调用)，如果没有那么会去找有没有成员变量_name,有那么返回_name的值，如果没有那么就去找有没有叫name成员变量,如果有name 变量返回name 的值， 如果没有 程序崩溃
     
     为了防止崩溃要写出
     - (id)valueForUndefinedKey:(NSString *)key

     */
    NSLog(@"name2:%@",name);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


