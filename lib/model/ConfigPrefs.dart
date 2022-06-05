class ConfigPrefs{
  int _opcaoNotificacao;
  String _usuarioMAL;
  String horarioNotificacao;
  String tempoAposOEpisodioParaDispararNotificacao;
 
  get opcaoNotificacao => this._opcaoNotificacao;

  set opcaoNotificacao( value) => this._opcaoNotificacao = value;

  get usuarioMAL => this._usuarioMAL;

  set usuarioMAL( value) => this._usuarioMAL = value;

  get getHorarioNotificacao => this.horarioNotificacao;

  set setHorarioNotificacao( horarioNotificacao) => this.horarioNotificacao = horarioNotificacao;

  get getTempoAposOEpisodioParaDispararNotificacao => this.tempoAposOEpisodioParaDispararNotificacao;

  set setTempoAposOEpisodioParaDispararNotificacao( tempoAposOEpisodioParaDispararNotificacao) => this.tempoAposOEpisodioParaDispararNotificacao = tempoAposOEpisodioParaDispararNotificacao;
}