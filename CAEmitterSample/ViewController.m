//
//  ViewController.m
//  CAEmitterSample
//
//  Created by shuichi on 13/03/12.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>


#define kBirthRateBasic 1000
#define kBirthRateFirework 1


@interface ViewController ()
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedCtl;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, strong) CAEmitterLayer *emitterLayer;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    
    self.emitterLayer = [CAEmitterLayer layer];
    self.emitterLayer.renderMode = kCAEmitterLayerAdditive;
    [self.view.layer addSublayer:self.emitterLayer];

    [self segmentChanged:self.segmentedCtl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -------------------------------------------------------------------
#pragma mark Private

- (void)startBasic {
    
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
    UIImage *image = [UIImage imageNamed:@"particle.png"];
    emitterCell.contents = (__bridge id)(image.CGImage);
    emitterCell.emissionLongitude = M_PI * 2;
    emitterCell.emissionRange = M_PI * 2;
    emitterCell.birthRate = kBirthRateBasic;
    emitterCell.lifetimeRange = 1.2;
    emitterCell.velocity = 240;
    emitterCell.color = [UIColor colorWithRed:0.89
                                        green:0.56
                                         blue:0.36
                                        alpha:0.5].CGColor;
    emitterCell.name = @"basic";
    
    self.emitterLayer.emitterCells = @[emitterCell];

}

- (void)startFireworks {

    // パーティクル画像
    UIImage *particleImage = [UIImage imageNamed:@"particle.png"];
    
    // 花火自体の発生源
    CAEmitterCell *baseCell = [CAEmitterCell emitterCell];
    baseCell.emissionLongitude = -M_PI / 2;
    baseCell.emissionLatitude = 0;
    baseCell.emissionRange = M_PI / 5;
    baseCell.lifetime = 2.0;
    baseCell.birthRate = kBirthRateFirework;
    baseCell.velocity = 400;
    baseCell.velocityRange = 50;
    baseCell.yAcceleration = 300;
    baseCell.color = CGColorCreateCopy([UIColor colorWithRed:0.5
                                                       green:0.5
                                                        blue:0.5
                                                       alpha:0.5].CGColor);
    baseCell.redRange   = 0.5;
    baseCell.greenRange = 0.5;
    baseCell.blueRange  = 0.5;
    baseCell.alphaRange = 0.5;
    baseCell.name = @"fireworks";

    // 上昇中のパーティクルの発生源
    CAEmitterCell *risingCell = [CAEmitterCell emitterCell];
    risingCell.contents = (__bridge id)particleImage.CGImage;
    risingCell.emissionLongitude = (4 * M_PI) / 2;
    risingCell.emissionRange = M_PI / 7;
    risingCell.scale = 0.4;
    risingCell.velocity = 100;
    risingCell.birthRate = 50;
    risingCell.lifetime = 1.5;
    risingCell.yAcceleration = 350;
    risingCell.alphaSpeed = -0.7;
    risingCell.scaleSpeed = -0.1;
    risingCell.scaleRange = 0.1;
    risingCell.beginTime = 0.01;
    risingCell.duration = 0.7;

    // 破裂後に飛散するパーティクルの発生源
    CAEmitterCell *sparkCell = [CAEmitterCell emitterCell];
    sparkCell.contents = (__bridge id)particleImage.CGImage;
    sparkCell.emissionRange = 2 * M_PI;
    sparkCell.birthRate = 8000;
    sparkCell.scale = 0.5;
    sparkCell.velocity = 130;
    sparkCell.lifetime = 3.0;
    sparkCell.yAcceleration = 80;
    sparkCell.beginTime = risingCell.lifetime;
    sparkCell.duration = 0.1;
    sparkCell.alphaSpeed = -0.1;
    sparkCell.scaleSpeed = -0.1;
    
    // baseCellからrisingCellとsparkCellを発生させる
    baseCell.emitterCells = [NSArray arrayWithObjects:risingCell, sparkCell, nil];

    // baseCellはemitterLayerから発生させる
    self.emitterLayer.emitterCells = [NSArray arrayWithObjects:baseCell, nil];
}




#pragma mark -------------------------------------------------------------------
#pragma mark IBAction

- (IBAction)segmentChanged:(UISegmentedControl *)sender {

    CGSize size = self.view.bounds.size;

    switch (sender.selectedSegmentIndex) {
        case 0:
        default:
            [self startBasic];
            self.emitterLayer.emitterPosition = CGPointMake(size.width / 2, size.height * 2 / 5);
            break;

        case 1:
            [self startFireworks];
            CGSize size = self.view.bounds.size;
            self.emitterLayer.emitterPosition = CGPointMake(size.width / 2, size.height * 4 / 5);
            break;
    }
    
    self.slider.value = 1.0;
}

- (IBAction)sliderChanged:(UISlider *)sender {

    switch (self.segmentedCtl.selectedSegmentIndex) {
        case 0:
        default:
        {
            float newValue = sender.value * kBirthRateBasic;
            NSLog(@"newValue:%f", newValue);
            [self.emitterLayer setValue:@(newValue)
                             forKeyPath:@"emitterCells.basic.birthRate"];
            break;
        }
        case 1:
        {
            float newValue = sender.value * kBirthRateFirework;
            NSLog(@"newValue:%f", newValue);
            [self.emitterLayer setValue:@(newValue)
                             forKeyPath:@"emitterCells.fireworks.birthRate"];
            break;
        }
    }
    
}

@end
