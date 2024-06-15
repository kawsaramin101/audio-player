// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_song_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaylistSongCollection on Isar {
  IsarCollection<PlaylistSong> get playlistSongs => this.collection();
}

const PlaylistSongSchema = CollectionSchema(
  name: r'PlaylistSong',
  id: 5504452839331217943,
  properties: {
    r'order': PropertySchema(
      id: 0,
      name: r'order',
      type: IsarType.long,
    )
  },
  estimateSize: _playlistSongEstimateSize,
  serialize: _playlistSongSerialize,
  deserialize: _playlistSongDeserialize,
  deserializeProp: _playlistSongDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'playlist': LinkSchema(
      id: 881135836434810494,
      name: r'playlist',
      target: r'Playlist',
      single: true,
    ),
    r'song': LinkSchema(
      id: 5777456071085606937,
      name: r'song',
      target: r'Song',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _playlistSongGetId,
  getLinks: _playlistSongGetLinks,
  attach: _playlistSongAttach,
  version: '3.1.0+1',
);

int _playlistSongEstimateSize(
  PlaylistSong object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _playlistSongSerialize(
  PlaylistSong object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.order);
}

PlaylistSong _playlistSongDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlaylistSong();
  object.id = id;
  object.order = reader.readLong(offsets[0]);
  return object;
}

P _playlistSongDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playlistSongGetId(PlaylistSong object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playlistSongGetLinks(PlaylistSong object) {
  return [object.playlist, object.song];
}

void _playlistSongAttach(
    IsarCollection<dynamic> col, Id id, PlaylistSong object) {
  object.id = id;
  object.playlist.attach(col, col.isar.collection<Playlist>(), r'playlist', id);
  object.song.attach(col, col.isar.collection<Song>(), r'song', id);
}

extension PlaylistSongQueryWhereSort
    on QueryBuilder<PlaylistSong, PlaylistSong, QWhere> {
  QueryBuilder<PlaylistSong, PlaylistSong, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaylistSongQueryWhere
    on QueryBuilder<PlaylistSong, PlaylistSong, QWhereClause> {
  QueryBuilder<PlaylistSong, PlaylistSong, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlaylistSongQueryFilter
    on QueryBuilder<PlaylistSong, PlaylistSong, QFilterCondition> {
  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlaylistSongQueryObject
    on QueryBuilder<PlaylistSong, PlaylistSong, QFilterCondition> {}

extension PlaylistSongQueryLinks
    on QueryBuilder<PlaylistSong, PlaylistSong, QFilterCondition> {
  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> playlist(
      FilterQuery<Playlist> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'playlist');
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition>
      playlistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'playlist', 0, true, 0, true);
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> song(
      FilterQuery<Song> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'song');
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterFilterCondition> songIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'song', 0, true, 0, true);
    });
  }
}

extension PlaylistSongQuerySortBy
    on QueryBuilder<PlaylistSong, PlaylistSong, QSortBy> {
  QueryBuilder<PlaylistSong, PlaylistSong, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }
}

extension PlaylistSongQuerySortThenBy
    on QueryBuilder<PlaylistSong, PlaylistSong, QSortThenBy> {
  QueryBuilder<PlaylistSong, PlaylistSong, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<PlaylistSong, PlaylistSong, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }
}

extension PlaylistSongQueryWhereDistinct
    on QueryBuilder<PlaylistSong, PlaylistSong, QDistinct> {
  QueryBuilder<PlaylistSong, PlaylistSong, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }
}

extension PlaylistSongQueryProperty
    on QueryBuilder<PlaylistSong, PlaylistSong, QQueryProperty> {
  QueryBuilder<PlaylistSong, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlaylistSong, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }
}
