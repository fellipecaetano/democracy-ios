import RxSwift
import Alamofire
import RxAlamofire

func LoadPoliticiansEpic(actions: Observable<Action>) -> Observable<Action> {
    let sessionManager = SessionManager(configuration: AppSessionConfigurationFactory.api())

    return LoadPoliticiansEpic(
        actions: actions,
        value: { request in
            sessionManager.request(request).rx.value()
        }
    )
}

func LoadPoliticiansEpic(actions: Observable<Action>,
                         value: @escaping (Request) -> Single<[Politician]>) -> Observable<Action> {
    return actions
        .map(RequestFactory.request)
        .unwrap()
        .map(APIDefaults.enhanceRequest)
        .flatMapLatest(value)
        .map(PoliticiansAction.load)
        .catchError(pipe(PoliticiansAction.fail, Observable.just))
}

private struct RequestFactory {
    static func request(forAction action: Action) -> Request? {
        switch action {
        case PoliticiansAction.startLoading:
            return Request(
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
