import RxSwift
import Alamofire

func LoadPoliticiansEpic(actions: Observable<Action>) -> Observable<Action> {
    let sessionManager = SessionManager(configuration: AppSessionConfigurationFactory.api())
    return LoadPoliticiansEpic(actions: actions, values: sessionManager.rx.value(request:))
}

func LoadPoliticiansEpic(actions: Observable<Action>,
                         values: @escaping (Request<[Politician]>) -> Observable<[Politician]>) -> Observable<Action> {
    return actions
        .map(RequestFactory.request(forAction:))
        .unwrap()
        .map(APIDefaults.enhanceRequest)
        .flatMap(values)
        .map(PoliticiansAction.load)
        .catchError(pipe(PoliticiansAction.fail, Observable.just(_:)))
}

private struct RequestFactory {
    static func request(forAction action: Action) -> Request<[Politician]>? {
        switch action {
        case PoliticiansAction.startLoading:
            return Request<[Politician]>(
                url: URL(string: "/politicians")!,
                method: .get,
                parameters: [:],
                headers: [:],
                parameterEncoding: URLEncoding()
            )

        default:
            return nil
        }
    }
}
