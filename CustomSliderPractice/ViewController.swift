//
//  ViewController.swift
//  CustomSliderPractice
//
//  Created by Daisaku Ejiri on 2022/10/24.
//

import UIKit
import RxRelay
import RxSwift

class ViewController: UIViewController {

  let bag = DisposeBag()
  
  let barViewWidth: CGFloat = 50
  let barViewHeight: CGFloat = 300
  
  let labelWidth: CGFloat = 100
  
  var viewWidth: CGFloat {
    view.bounds.width
  }
  
  var viewHeight: CGFloat {
    view.bounds.height
  }

  lazy var label: UILabel = {
    let label = UILabel()
    label.backgroundColor = .systemGray4
    return label
  }()
  
  lazy var barView: BarView = {
    let barView = BarView(width: barViewWidth, height: barViewHeight)
    barView.backgroundColor = .yellow
    return barView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    view.addSubview(barView)
    view.addSubview(label)
    
    barView.yValueRelay.subscribe(onNext: { [weak self] value in
      self?.label.text = "\(value)"
    })
    .disposed(by: bag)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layout()
  }
  
  private func layout() {
    barView.frame = CGRect(x: viewWidth/2 - barViewWidth/2, y: viewHeight/2 - barViewHeight/2, width: barViewWidth, height: barViewHeight)
    label.frame = CGRect(x: viewWidth/2 - labelWidth/2, y: 100, width: labelWidth, height: 50)
  }
}

class BarView: UIView {
  
  var width: CGFloat
  var height: CGFloat
  var startTransform: CGAffineTransform?
  var yValueRelay: BehaviorRelay<CGFloat> = BehaviorRelay(value: 0)
  
  lazy var scaleBar: UIView = {
    let scaleBar = UIView()
    scaleBar.translatesAutoresizingMaskIntoConstraints = false
    scaleBar.backgroundColor = .blue
    // initial anchorPoint is (0.5, 0.5) and the shape stretches from the center
    scaleBar.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    return scaleBar
  }()
  
  init(width: CGFloat, height: CGFloat) {
    self.width = width
    self.height = height
    super.init(frame: .zero)
    self.addSubview(scaleBar)
    layout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func layout() {
    scaleBar.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    scaleBar.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    scaleBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    scaleBar.heightAnchor.constraint(equalToConstant: 1).isActive = true
    startTransform = scaleBar.transform // Identity
    scaleBar.transform = startTransform?.scaledBy(x: 1, y: 0) ?? CGAffineTransform.identity // to hide initial scaleBar
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let yValue = height - max(min(height, touch.location(in: self).y), 0)
    scaleBar.transform = startTransform?.scaledBy(x: 1, y: yValue) ?? CGAffineTransform.identity
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let yValue = height - max(min(height, touch.location(in: self).y), 0)
    yValueRelay.accept(yValue)
    scaleBar.transform = startTransform?.scaledBy(x: 1, y: yValue) ?? CGAffineTransform.identity
  }
}

