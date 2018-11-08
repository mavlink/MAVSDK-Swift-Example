import Foundation
import Dronecode_SDK_Swift
import RxSwift

class CoreManager {

    static let shared = CoreManager()

    let disposeBag = DisposeBag()

    let core = Core()
    let telemetry = Telemetry(address: "localhost", port: 50051)
    let action = Action(address: "localhost", port: 50051)
    let mission = Mission(address: "localhost", port: 50051)
    let camera = Camera(address: "localhost", port: 50051)

    private init() {}

    // NOTE: that's a workaround for now, but this should really be done in the
    // SDK, and one would use `telemetry.positionObservable.subscribe()` directly.
    lazy var position = createPositionObservable()

    private func createPositionObservable() -> Observable<Position> {
        let positionConnectable = self.telemetry.positionObservable.replay(1)
        positionConnectable.connect().disposed(by: disposeBag)

        return positionConnectable.asObservable()
    }

    lazy var startCompletable = createStartCompletable()

    private func createStartCompletable() -> Observable<Never> {
        let startCompletable = core.connect().asObservable().replay(1)
        startCompletable.connect().disposed(by: disposeBag)
        
        return startCompletable.asObservable()
    }
}
