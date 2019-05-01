//
//  SSSettingsViewController.swift
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//


enum SSSynthVoice {
	case Sampled
	case Tick
	case Sine
	case Square
	case Triangle
}

enum SSTemperament {
	case Equal
	case JustC
}

protocol SSChangeSettingsProtocol
{
	func showPartNames(_ pn : Bool)
	func showBarNumbers(_ bn : Bool)
}

protocol SSChangeWaveformSettingsProtocol
{
	func changeSound(_ voice : SSSynthVoice)
	func changeSymmetry(_ symmetry : Float) // 0.0 .. 1.0
	func changeRiseFall(_ risefall : Float) // 0.0 .. 1.0
	func changeTemperament(_ temperament : SSTemperament)
}

class SSSettingsViewController : UIViewController
{
	enum SoundControlSegments {
		case Sampled
		case Sine
		case Square
		case Triangle
	}
	
	@IBOutlet var partNamesSwitch: UISwitch!
	@IBOutlet var barNumbersSwitch: UISwitch!
	@IBOutlet var soundSelector: UISegmentedControl!
	@IBOutlet var symmetryControl: UISlider!
	@IBOutlet var temperamentControl: UISegmentedControl!
	@IBOutlet var waveformView: WaveformView!
	@IBOutlet var risefallControl: UISlider!
	
	@IBOutlet var temperamentLabel: UILabel!
	@IBOutlet var symmetryLabel: UILabel!
	@IBOutlet var risefallLabel: UILabel!
	
	private var showPartNames: Bool
	private var showBarNumbers: Bool
	private var synthVoice : SSSynthVoice
	private var temperament : SSTemperament
	private var symmetry : Float
	private var risefall : Float
	
	var settingsChanger : SSChangeSettingsProtocol?
	var waveformSettingsChanger : SSChangeWaveformSettingsProtocol?

	public required init?(coder aDecoder: NSCoder)
	{
		showPartNames = false
		showBarNumbers = false
		synthVoice = .Sampled
		temperament = .Equal
		symmetry = 0.5
		risefall = 0.5
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		partNamesSwitch.isOn = showPartNames
		barNumbersSwitch.isOn = showBarNumbers
		switch synthVoice {
		case .Sampled: soundSelector.selectedSegmentIndex = 0
		case .Tick: soundSelector.selectedSegmentIndex = 0
		case .Sine: soundSelector.selectedSegmentIndex = 1
		case .Square: soundSelector.selectedSegmentIndex = 2
		case .Triangle: soundSelector.selectedSegmentIndex = 3
		}
		temperamentControl.selectedSegmentIndex = temperament == .Equal ? 0 : 1
		symmetryControl.value = symmetry
		risefallControl.value = risefall
		updateEnabled()
		updateWaveformView()
	}

	func set(partNames : Bool, barNumbers: Bool, voice : SSSynthVoice, temper : SSTemperament, symm : Float, rise : Float,
			 settingsProto: SSChangeSettingsProtocol, wSettingsProto: SSChangeWaveformSettingsProtocol?)
	{
		showPartNames = partNames
		showBarNumbers = barNumbers
		synthVoice = voice
		temperament = temper
		symmetry = symm
		risefall = rise
		settingsChanger = settingsProto
		waveformSettingsChanger = wSettingsProto
	}

	func updateEnabled()
	{
		temperamentControl.isHidden = waveformSettingsChanger == nil || !(synthVoice == .Sine || synthVoice == .Square || synthVoice == .Triangle)
		temperamentLabel.isHidden = waveformSettingsChanger == nil || temperamentControl.isHidden
		waveformView.isHidden = waveformSettingsChanger == nil || !(synthVoice == .Sine || synthVoice == .Square || synthVoice == .Triangle)
		symmetryControl.isHidden = waveformSettingsChanger == nil || !(synthVoice == .Square || synthVoice == .Triangle)
		symmetryLabel.isHidden = waveformSettingsChanger == nil || symmetryControl.isHidden
		risefallControl.isHidden = waveformSettingsChanger == nil || synthVoice != .Square
		risefallLabel.isHidden = waveformSettingsChanger == nil || risefallControl.isHidden
	}
	
	@IBAction func changePartNames(_ sender: Any) {
		settingsChanger?.showPartNames(partNamesSwitch.isOn)
	}

	@IBAction func changeBarNumbers(_ sender: Any) {
		settingsChanger?.showBarNumbers(barNumbersSwitch.isOn)
	}

	@IBAction func changeSOundControl(_ sender: Any) {
		switch soundSelector.selectedSegmentIndex
		{
		case 0: synthVoice = SSSynthVoice.Sampled
			
		case 1:	synthVoice = SSSynthVoice.Sine
			
		case 2:	synthVoice = SSSynthVoice.Square
			
		case 3:	synthVoice = SSSynthVoice.Triangle

		default:break
		}
		waveformSettingsChanger?.changeSound(synthVoice)
		updateEnabled()
		updateWaveformView()
	}

	func updateWaveformView()
	{
		switch synthVoice
		{
		case SSSynthVoice.Sampled:	waveformView.isHidden = true
			
		case SSSynthVoice.Sine:
			waveformView.isHidden = false
			waveformView.waveform = WaveformView.Waveform.Sine
			
		case SSSynthVoice.Square:
			waveformView.isHidden = false
			waveformView.waveform = WaveformView.Waveform.Square
			
		case SSSynthVoice.Triangle:
			waveformView.isHidden = false
			waveformView.waveform = WaveformView.Waveform.Triangle
			
		default:break
		}
		waveformView.symmetry = symmetryControl.value
		waveformView.risefall = risefallControl.value
	}
	
	@IBAction func changeSymmetrySlider(_ sender: Any) {
		waveformSettingsChanger?.changeSymmetry(symmetryControl.value)
		waveformView.symmetry = symmetryControl.value
	}
	
	@IBAction func temperamentSelected(_ sender: Any) {
		let control = sender as! UISegmentedControl
		waveformSettingsChanger?.changeTemperament(control.selectedSegmentIndex == 0 ? SSTemperament.Equal : SSTemperament.JustC)
	}
	
	@IBAction func changeRisefallControl(_ sender: Any) {
		let control = sender as! UISlider
		waveformSettingsChanger?.changeRiseFall(control.value)
		waveformView.risefall = control.value
	}
	
	@IBAction func OkTapped(_ sender: Any) {
		dismiss(animated: true)
	}
}
