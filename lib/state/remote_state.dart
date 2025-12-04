class RemoteState<T> {
  const RemoteState();
}

class RemoteStateLoading<T> extends RemoteState<T> {
  const RemoteStateLoading();
}

class RemoteStateSuccess<T> extends RemoteState<T> {
  final T data;
  const RemoteStateSuccess(this.data);
}

class RemoteStateError<T> extends RemoteState<T> {
  final String message;
  const RemoteStateError(this.message);
}
