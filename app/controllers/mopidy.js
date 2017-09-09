// Generated by CoffeeScript 1.7.1
'use strict';
var Emitter, MopidyController, Queue, Track, bb, helpers,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

bb = require('backbone');

Emitter = require('events').EventEmitter;

helpers = require('../lib/mopidy.js');

Track = (function(_super) {
  __extends(Track, _super);

  function Track() {
    return Track.__super__.constructor.apply(this, arguments);
  }

  Track.prototype.idAttribute = 'uri';

  return Track;

})(bb.Model);

Queue = (function(_super) {
  __extends(Queue, _super);

  function Queue() {
    return Queue.__super__.constructor.apply(this, arguments);
  }

  Queue.prototype.model = Track;

  return Queue;

})(bb.Collection);

MopidyController = (function(_super) {
  __extends(MopidyController, _super);

  function MopidyController(app) {
    this.app = app;
    this.mopidy = app.set('mopidy');
    this.clients = app.set('dnode clients');
    this.db = app.set('db');
    this.queue = new Queue;
    this.current = null;
    this.setupListeners();
    this.checkPlaying();
  }

  MopidyController.prototype.setupListeners = function() {
    this.app.on('queue:add', (function(_this) {
      return function(track, addr) {
        _this.queueAdd(track, addr);
      };
    })(this));
    this.app.on('queue:downvote', (function(_this) {
      return function(track, addr) {
        _this.queueDownvote(track, addr);
      };
    })(this));
    this.app.on('current:vote', (function(_this) {
      return function(clientId) {
        _this.votePlaying(clientId, 1);
      };
    })(this));
    this.app.on('current:downvote', (function(_this) {
      return function(clientId) {
        _this.votePlaying(clientId, -1);
      };
    })(this));
    this.mopidy.on('event:trackPlaybackStarted', (function(_this) {
      return function(track) {
        _this.trackChange(track.tl_track.track);
      };
    })(this));
    this.mopidy.on('event:playbackStateChanged', (function(_this) {
      return function(state) {
        if ('stopped' === state.new_state) {
          _this.current = null;
          if (0 === _this.queue.length) {
            _this.queueUpdate();
          }
        }
        _this.stateChanged(state.new_state);
      };
    })(this));
    this.mopidy.on('event:seeked', (function(_this) {
      return function(position) {
        var client, _i, _len, _ref, _ref1;
        _ref = _this.clients;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          client = _ref[_i];
          if ((_ref1 = client.state) != null) {
            if (typeof _ref1.change === "function") {
              _ref1.change('playing', position);
            }
          }
        }
        client = null;
      };
    })(this));
    this.queue.on('add change', (function(_this) {
      return function(track) {
        var client, _i, _len, _ref, _ref1;
        track = track.toJSON();
        _ref = _this.clients;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          client = _ref[_i];
          if ((_ref1 = client.queue) != null) {
            if (typeof _ref1.trackChanged === "function") {
              _ref1.trackChanged(track);
            }
          }
        }
        client = null;
      };
    })(this));
    this.queue.on('remove', (function(_this) {
      return function(track) {
        var client, _i, _len, _ref, _ref1;
        track = track.toJSON();
        _ref = _this.clients;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          client = _ref[_i];
          if ((_ref1 = client.queue) != null) {
            if (typeof _ref1.trackRemoved === "function") {
              _ref1.trackRemoved(track);
            }
          }
        }
        client = null;
      };
    })(this));
    return this;
  };

  MopidyController.prototype.checkPlaying = function() {
    var gotQueue, gotState, playing, trackSet;
    gotState = (function(_this) {
      return function(state) {
        if (state === 'playing') {
          return;
        }
        _this.db.getQueue(_this.app.set('queue max'), gotQueue);
      };
    })(this);
    gotQueue = (function(_this) {
      return function(err, tracks) {
        var track;
        if (err) {
          throw err;
        }
        if (!(0 < tracks.length)) {
          return;
        }
        _this.queue.set(tracks);
        track = helpers.cleanTrack(tracks[0]);
        helpers.setNextTrack(_this.mopidy, tracks[0], trackSet);
      };
    })(this);
    trackSet = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        _this.mopidy.playback.play(null).then(playing, function(err) {
          throw err;
        });
      };
    })(this);
    playing = function() {};
    this.mopidy.playback.getState().then(gotState, function(err) {
      throw err;
    });
    return this;
  };

  MopidyController.prototype.getQueue = function(done) {
    var gotQueue;
    gotQueue = (function(_this) {
      return function(err, tracks) {
        if (err) {
          return done(err);
        }
        done(null, tracks);
        _this.queue.set(tracks);
      };
    })(this);
    this.db.getQueue(this.app.set('queue max'), gotQueue);
    return this;
  };

  MopidyController.prototype.queueAdd = function(track, addr) {
    var gotVotes, votedTrack;
    votedTrack = (function(_this) {
      return function(err) {
        if (err) {
          return;
        }
        _this.db.getVotes([track], gotVotes);
      };
    })(this);
    gotVotes = (function(_this) {
      return function(err) {
        if (err) {
          return;
        }
        _this.triggerTrackChanged(track);
      };
    })(this);
    this.db.voteTrack(track, addr, votedTrack);
    return this;
  };

  MopidyController.prototype.queueDownvote = function(track, addr) {
    var downvoted, gotVotes, trackRemoved;
    downvoted = (function(_this) {
      return function(err) {
        if (err) {
          return;
        }
        _this.db.getVotes([track], gotVotes);
      };
    })(this);
    gotVotes = (function(_this) {
      return function(err) {
        if (err) {
          return;
        }
        if (app.set('vote limit') >= track.votes) {
          _this.db.removeTrack(track, trackRemoved);
        } else {
          _this.triggerTrackChanged(track);
        }
      };
    })(this);
    trackRemoved = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        _this.queueUpdate();
      };
    })(this);
    this.db.downvoteTrack(track, addr, downvoted);
    return this;
  };

  MopidyController.prototype.triggerTrackChanged = function() {
    this.queueUpdate();
    this.checkPlaying();
    return this;
  };

  MopidyController.prototype.queueUpdate = function(done) {
    var gotQueue, nextTrackSet;
    gotQueue = (function(_this) {
      return function(err, tracks) {
        var client, _i, _len, _ref, _ref1;
        if (err) {
          throw err;
        }
        _this.queue.set(tracks);
        if (0 === _this.queue.length && !_this.current) {
          _ref = _this.clients;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            client = _ref[_i];
            if ((_ref1 = client.current) != null) {
              if (typeof _ref1.set === "function") {
                _ref1.set(null, 0);
              }
            }
          }
          client = null;
          _this.mopidy.tracklist.clear();
          return;
        } else if (0 === _this.queue.length) {
          helpers.clear(_this.mopidy, function() {});
          return;
        }
        helpers.setNextTrack(_this.mopidy, tracks[0], nextTrackSet);
      };
    })(this);
    nextTrackSet = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        if (done) {
          done();
        }
      };
    })(this);
    this.db.getQueue(this.app.set('queue max'), gotQueue);
    return this;
  };

  MopidyController.prototype.queueRefresh = function() {
    var gotQueue;
    gotQueue = (function(_this) {
      return function(err, tracks) {
        var client, _i, _len, _ref, _ref1;
        if (err) {
          return;
        }
        _ref = _this.clients;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          client = _ref[_i];
          if ((_ref1 = client.queue) != null) {
            if (typeof _ref1.refresh === "function") {
              _ref1.refresh(tracks);
            }
          }
        }
        client = null;
      };
    })(this);
    this.db.getQueue(this.app.set('queue max'), gotQueue);
    return this;
  };

  MopidyController.prototype.trackChange = function(track) {
    var gotTracks, gotVotes, trackReset;
    gotTracks = (function(_this) {
      return function(err, tracks) {
        if (err) {
          throw err;
        }
        if (!(tracks && tracks[0])) {
          return;
        }
        track = tracks[0];
        _this.db.getVotes([track], gotVotes);
      };
    })(this);
    gotVotes = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        _this.current = {
          votes: track.votes,
          votesHash: track.votesHash,
          previous: track.previous
        };
        _this.db.resetTrack(track, trackReset);
      };
    })(this);
    trackReset = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        _this.current.updated = track.updated;
        _this.queueUpdate();
        _this.setPlaying(track, 0);
      };
    })(this);
    this.db.getTracks([track.uri], gotTracks);
    return this;
  };

  MopidyController.prototype.setPlaying = function(track, position) {
    var client, _i, _len, _ref, _ref1;
    if (position == null) {
      position = 0;
    }
    track.votes = this.current.votes;
    track.votesHash = this.current.votesHash;
    track.previous = this.current.previous;
    _ref = this.clients;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      client = _ref[_i];
      if ((_ref1 = client.current) != null) {
        if (typeof _ref1.set === "function") {
          _ref1.set(track, position);
        }
      }
    }
    client = null;
    return this;
  };

  MopidyController.prototype.votePlaying = function(clientId, amount) {
    var client, gotCurrentTrack, gotTimePosition, onNext, queueUpdated, s, setVotes, trackRemoved, value, votes, _ref;
    if (!this.current) {
      return this;
    }
    s = {};
    this.current.votesHash[clientId] = +amount;
    votes = 0;
    _ref = this.current.votesHash;
    for (client in _ref) {
      value = _ref[client];
      votes += +value;
    }
    this.current.votes = votes;
    gotCurrentTrack = (function(_this) {
      return function(track) {
        if (!track) {
          return;
        }
        s.track = track;
        if (app.set('vote limit') >= votes) {
          _this.db.removeTrack(track, trackRemoved);
        } else {
          _this.db.setPooledVotes(track, votes, setVotes);
        }
      };
    })(this);
    trackRemoved = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        _this.current = null;
        _this.queueUpdate(queueUpdated);
      };
    })(this);
    queueUpdated = (function(_this) {
      return function() {
        _this.mopidy.playback.next().then(onNext, function(err) {
          throw err;
        });
      };
    })(this);
    onNext = function() {};
    setVotes = (function(_this) {
      return function(err) {
        if (err) {
          throw err;
        }
        _this.queueUpdate();
        _this.mopidy.playback.getTimePosition().then(gotTimePosition, function(err) {
          throw err;
        });
      };
    })(this);
    gotTimePosition = (function(_this) {
      return function(position) {
        _this.setPlaying(s.track, position);
      };
    })(this);
    this.mopidy.playback.getCurrentTrack().then(gotCurrentTrack, function(err) {
      throw err;
    });
    return this;
  };

  MopidyController.prototype.stateChanged = function(state) {
    var gotTimePosition;
    gotTimePosition = (function(_this) {
      return function(position) {
        var client, _i, _len, _ref, _ref1;
        _ref = _this.clients;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          client = _ref[_i];
          if ((_ref1 = client.state) != null) {
            if (typeof _ref1.change === "function") {
              _ref1.change(state, position || 0);
            }
          }
        }
        client = null;
      };
    })(this);
    if ('stopped' === state) {
      gotTimePosition(0);
      return this;
    }
    this.mopidy.playback.getTimePosition().then(gotTimePosition, function(err) {
      throw err;
    });
    return this;
  };

  MopidyController.prototype.getPlaying = function(done) {
    var gotCurrentTrack, gotPosition, gotState, s;
    s = {};
    gotCurrentTrack = (function(_this) {
      return function(track) {
        if (!track) {
          return done();
        }
        if (!_this.current) {
          _this.current = {
            votes: 0,
            votesHash: {},
            previous: 0,
            updated: Date.now()
          };
        }
        track.votes = _this.current.votes;
        track.votesHash = _this.current.votesHash;
        track.previous = _this.current.previous;
        track.updated = _this.current.updated;
        s.track = track;
        _this.mopidy.playback.getState().then(gotState, function(err) {
          return done(err);
        });
      };
    })(this);
    gotState = (function(_this) {
      return function(state) {
        s.state = 'playing' === state ? state : 'paused';
        _this.mopidy.playback.getTimePosition().then(gotPosition, function(err) {
          return done(err);
        });
      };
    })(this);
    gotPosition = (function(_this) {
      return function(position) {
        done(null, s.track, s.state, position);
      };
    })(this);
    this.mopidy.playback.getCurrentTrack().then(gotCurrentTrack, function(err) {
      return done(err);
    });
    return this;
  };

  return MopidyController;

})(Emitter);

module.exports = MopidyController;