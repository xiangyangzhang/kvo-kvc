//
//  RootViewController.m
//  NSFetchedResultsControllerDemo
//
//  Created by LZXuan on 14-9-24.
//  Copyright (c) 2014年 LZXuan. All rights reserved.
//

#import "RootViewController.h"
#import <CoreData/CoreData.h>
#import "Person.h"
#import "CoreDataManager.h"
#import "ListTableViewController.h"


@interface RootViewController ()
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
#pragma mark - coreData
- (IBAction)add:(id)sender {
    //增加人
    //不能这样创建 Person *addPerson = [[Person alloc] init]; //因为 内部  没有动态生成 setter和getter方法
    //需要这样创建 调用下面的方法就会在数据库中增加
    Person *addPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:[[CoreDataManager shareManager]objContext]];
    NSLog(@"addPerson is :%@",[addPerson class]);
    addPerson.name = self.nameTextField.text;
    addPerson.fName = [addPerson.name substringToIndex:1];
    NSLog(@"fName:%@",addPerson.fName);
    addPerson.age = [NSNumber numberWithInt:[self.ageTextF.text intValue]];
    [[CoreDataManager shareManager] insertDataWithModel:addPerson];
}
- (IBAction)delete:(id)sender {
    //删除  根据人名
    [[CoreDataManager shareManager] deleteModelWithPerstring:self.nameTextField.text];
}

- (IBAction)look:(id)sender {
    //查看所有的打印
    NSArray *results = [[CoreDataManager shareManager] fetchAllData];
    [results enumerateObjectsUsingBlock:^(Person  *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@->%@",obj.name,[obj.age stringValue]);
    }];
    //查看之后 弹出一个tableView 显示所有人信息
    
    ListTableViewController *lvc = [[ListTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:lvc animated:YES];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nameTextField resignFirstResponder];
    [self.ageTextF resignFirstResponder];
}
- (IBAction)update:(id)sender {

    //根据名字修改 年龄
    [[CoreDataManager shareManager] updataModelWithPer:self.nameTextField.text andObjAge:[NSNumber numberWithInt:[self.ageTextF.text intValue]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   // NSLog(@"view:%@",self.view);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
