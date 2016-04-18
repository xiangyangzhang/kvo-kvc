//
//  ListTableViewController.m
//  NSFetchedResultsControllerDemo
//
//  Created by LZXuan on 14-9-26.
//  Copyright (c) 2014年 LZXuan. All rights reserved.
//

#import "ListTableViewController.h"
#import <CoreData/CoreData.h>
#import "CoreDataManager.h"
#import "Person.h"

@interface ListTableViewController ()<NSFetchedResultsControllerDelegate,UITextFieldDelegate>
{
    UITextField *_nameTextField;
    UITextField *_ageTextField;
}
//和CoreData tableView NSFetchedResultsController 是结合使用
//tableView的数据 可以从 NSFetchedResultsController获取
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ListTableViewController
- (void)dealloc{
    NSLog(@"fetch_dealloc");
    //[NSFetchedResultsController deleteCacheWithName:@"root"];
}
#pragma mark - 查询数据
- (void)fetchAllData{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription * desption = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:[[CoreDataManager shareManager] objContext]];
    [request setEntity:desption];
    
    //设置取得的数据的缓冲值的最大值
    [request setFetchBatchSize:20];
   //必须要设置排序  按照分区排序 然后按照分区的age排序
    NSSortDescriptor * desciptor = [NSSortDescriptor sortDescriptorWithKey:@"fName" ascending:YES];
    NSSortDescriptor * desciptor2 = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    //必须要设置 比较排序 否则会崩溃
    [request setSortDescriptors:[NSArray arrayWithObjects:desciptor,desciptor2, nil]];
    //在CoreData为UITableView提供数据的时候，使用NSFetchedReslutsController能提高体验，因为用NSFetchedReslutsController去读数据的话，能最大效率的读取数据库，也方便数据变化后更新界面，
    //当我们设置好这个fetch的缓冲值的时候，我们就完成了创建 NSFetchedRequestController 并且将它传递给了fetch请求，但是这个方法其实还有以下几个参数：
    // 对于managed object 内容，我们值传递内容。
    //sectionnamekeypath允许我们按照某种属性来分组排列数据内容。
    //文件名的缓存名字应该被用来处理任何重复的任务，比如说设置分组或者排列数据等。
    
    //一个可选的key path作为section name。控制器用key path来把结果集拆分成各个section。（传nil代表只有一个section）
    //fetchedResultsController 需要和 coreData 产生关联
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[CoreDataManager shareManager] objContext] sectionNameKeyPath:@"fName" cacheName:nil];
    //fName 根据 fName 来进行分组  可以把fName一样的可以作为一组
    
    
    self.fetchedResultsController.delegate = self;
    NSError * error = nil;
    
    //操作我们的 fetchedResultsController 并且执行performFetch 方法来取得缓冲的第一批数据。
    //执行查询
    if ([self.fetchedResultsController performFetch:&error]){
        NSLog(@"success");
    }else{
        NSLog(@"error = %@",error);
    }
}
#pragma mark - 创建基本视图
- (void)creatBarButton {

    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStylePlain target:self action:@selector(itemClick:)];
    left.tag = 101;
    
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"delete" style:UIBarButtonItemStylePlain target:self action:@selector(itemClick:)];
    right.tag = 102;
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"update" style:UIBarButtonItemStylePlain target:self action:@selector(itemClick:)];
    right2.tag = 103;
    
    self.navigationItem.rightBarButtonItems=@[left,right,right2];
//    self.hidesBottomBarWhenPushed
    UIView *heardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    _nameTextField.placeholder = @"name";
    _nameTextField.delegate = self;
    _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [heardView addSubview:_nameTextField];
    
    
    _ageTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, 300, 30)];
    _ageTextField.placeholder = @"age";
    _ageTextField.delegate = self;
    _ageTextField.borderStyle = UITextBorderStyleRoundedRect;
    [heardView addSubview:_ageTextField];
    
    heardView.backgroundColor = [UIColor grayColor];
    self.tableView.tableHeaderView = heardView;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_nameTextField resignFirstResponder];
    [_ageTextField resignFirstResponder];
}
#pragma mark - add delete触发的方法
- (void)itemClick:(UIBarButtonItem *)item{
    switch (item.tag) {
        case 101: //add
        {
            [self add];
        }
            break;
        case 102://delete
        {
            [self delete];
        }
            break;
        case 103://update
        {
            [self update];
        }
            break;
        default:
            break;
    }
}
- (void)update{
    
    //根据名字修改 年龄
    [[CoreDataManager shareManager] updataModelWithPer:_nameTextField.text andObjAge:[NSNumber numberWithInt:[_ageTextField.text intValue]]];
}

- (void)add{
    if (_nameTextField.text.length == 0||_ageTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"用户名 年龄不能为空" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //增加人
    Person *addPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:[[CoreDataManager shareManager]objContext]];
    addPerson.name = _nameTextField.text;
    addPerson.age = [NSNumber numberWithInt:[_ageTextField.text intValue]];
    addPerson.fName = [addPerson.name substringToIndex:1];
    NSLog(@"fName:%@",addPerson.fName);
    [[CoreDataManager shareManager] insertDataWithModel:addPerson];
}
- (void)delete{
    if (_nameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    //删除  根据人名
    [[CoreDataManager shareManager] deleteModelWithPerstring:_nameTextField.text];
}
#pragma mark - 程序加载
- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchAllData];
    [self creatBarButton];
}
#pragma  mark -fetchedResultsController协议
//此方法执行时，说明数据已经发生了变化，通知tableview开始更新UI
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

//结束更新
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
//当数据发生变化时，点对点的更新tableview，这样大大的提高了更新效率
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell * cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            Person * stu = (Person *)[controller objectAtIndexPath:indexPath];
            [self  showModel:stu forCell:cell];
        }
            break;
            
        default:
            break;
    }
}

//点对点的更新section
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //section配置
    // return [[self.fetchedResultsControllersections] count];
    
    //row配置
    if ([[self.fetchedResultsController sections] count] > 0) {
        //获取指定分区
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        NSLog(@"number:%ld" ,[sectionInfo numberOfObjects]);
        return [sectionInfo numberOfObjects];
    }else{
        return 0;
    }
}
//分区标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}
//右侧索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    Person *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showModel:model forCell:cell];
    return cell;
}

- (void)showModel:(Person *)model forCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = [model.age stringValue];

}



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
