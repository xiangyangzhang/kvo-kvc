//
//  ViewController.m
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "ViewController.h"
#import "MyImageView.h"

#import "StudentModel.h"
#import "CoreDataManager.h"


#import <MobileCoreServices/MobileCoreServices.h>

#define kCellId @"Cell"
@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
- (IBAction)addClick:(id)sender;
- (IBAction)deleteClick:(id)sender;
- (IBAction)updateClick:(id)sender;
- (IBAction)fetchNameClick:(id)sender;
- (IBAction)fetchAllClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MyImageView *myImageView;
@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr  = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = 80;
    //注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellId];
    
    //增加图片点击
    [self addTapClick];
    
}
#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
//显示 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    StudentModel *model = self.dataArr[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"name:%@ score:%f",model.name,model.score.doubleValue];
    cell.imageView.image  = [UIImage imageWithData:model.headimage];
    return cell;
}

#pragma mark - UIImagePickerController
- (void)addTapClick {
    [self.myImageView addTarget:self action:@selector(imageClick:)];
}
- (void)imageClick:(MyImageView *)imageView {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //获取相册
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"choose");
    
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        //图片
        //获取原始图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.myImageView.image = image;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    [self.nameTextField resignFirstResponder];
    [self.scoreTextField resignFirstResponder];
}

- (IBAction)addClick:(id)sender {
    //调用增加
    [[CoreDataManager sharedManager] insertDataWithName:self.nameTextField.text score:self.scoreTextField.text.doubleValue headimage:UIImagePNGRepresentation(self.myImageView.image)];
}

- (IBAction)deleteClick:(id)sender {
    [[CoreDataManager sharedManager] deleteDataWithName:self.nameTextField.text];
}

- (IBAction)updateClick:(id)sender {
    //修改
    [[CoreDataManager sharedManager] updateDataWithName:self.nameTextField.text score:self.scoreTextField.text.doubleValue headimage:UIImagePNGRepresentation(self.myImageView.image)];
}

- (IBAction)fetchNameClick:(id)sender {
    [self.dataArr removeAllObjects];
    //根据名字查找
    NSArray *arr = [[CoreDataManager sharedManager] fetchDataWithName:self.nameTextField.text];
    [self.dataArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}

- (IBAction)fetchAllClick:(id)sender {
    [self.dataArr removeAllObjects];
    //传nil 表示查所有
    NSArray *arr = [[CoreDataManager sharedManager] fetchDataWithName:nil];
    [self.dataArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}
@end
