import 'dart:collection';

/// Estrutura de dados de Fila Circular (Ring / Circular Buffer) de capacidade fixa.
///
/// Mantém as últimas [capacity] amostras em memória com complexidade O(1) de inserção,
/// sem realocações dinâmicas contínuas de memória ou overhead de garbage collection,
/// garantindo renderização suave a alta taxa de quadros (60 FPS) sem engasgos.
class CircularBuffer<T> with IterableMixin<T> {
  final int capacity;
  final List<T?> _buffer;
  int _start = 0;
  int _size = 0;

  CircularBuffer(this.capacity)
      : assert(capacity > 0, 'A capacidade deve ser maior que zero'),
        _buffer = List<T?>.filled(capacity, null);

  /// Insere um novo item no buffer circular.
  /// Se atingir [capacity], sobrescreve o elemento mais antigo em O(1).
  void add(T item) {
    if (_size < capacity) {
      final index = (_start + _size) % capacity;
      _buffer[index] = item;
      _size++;
    } else {
      _buffer[_start] = item;
      _start = (_start + 1) % capacity;
    }
  }

  /// Adiciona múltiplos itens sequencialmente.
  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  /// Limpa todos os elementos do buffer.
  void clear() {
    _buffer.fillRange(0, capacity, null);
    _start = 0;
    _size = 0;
  }

  @override
  int get length => _size;

  @override
  bool get isEmpty => _size == 0;

  @override
  bool get isNotEmpty => _size > 0;

  /// Retorna se o buffer atingiu sua capacidade máxima.
  bool get isFull => _size == capacity;

  /// Elemento mais recente inserido no buffer.
  @override
  T get last {
    if (isEmpty) throw StateError('CircularBuffer está vazio');
    final index = (_start + _size - 1) % capacity;
    return _buffer[index] as T;
  }

  /// Elemento mais antigo no buffer.
  @override
  T get first {
    if (isEmpty) throw StateError('CircularBuffer está vazio');
    return _buffer[_start] as T;
  }

  /// Acessa o elemento pelo índice cronológico (0 = mais antigo, length - 1 = mais recente).
  T operator [](int index) {
    if (index < 0 || index >= _size) {
      throw RangeError.index(index, this, 'index');
    }
    final actualIndex = (_start + index) % capacity;
    return _buffer[actualIndex] as T;
  }

  @override
  Iterator<T> get iterator => _CircularBufferIterator<T>(this);

  @override
  List<T> toList({bool growable = true}) {
    final list = List<T>.generate(
      _size,
      (i) => this[i],
      growable: growable,
    );
    return list;
  }
}

class _CircularBufferIterator<T> implements Iterator<T> {
  final CircularBuffer<T> _buffer;
  int _index = -1;

  _CircularBufferIterator(this._buffer);

  @override
  T get current {
    if (_index < 0 || _index >= _buffer.length) {
      throw StateError('Iterador fora dos limites');
    }
    return _buffer[_index];
  }

  @override
  bool moveNext() {
    if (_index + 1 < _buffer.length) {
      _index++;
      return true;
    }
    return false;
  }
}
