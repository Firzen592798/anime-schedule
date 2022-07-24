class ConfigPrefs{
  int _opcaoNotificacao;
  String horarioNotificacao;
  String tempoAposOEpisodioParaDispararNotificacao;
 
  get opcaoNotificacao => this._opcaoNotificacao;

  set opcaoNotificacao( value) => this._opcaoNotificacao = value;

  get getHorarioNotificacao => this.horarioNotificacao;

  set setHorarioNotificacao( horarioNotificacao) => this.horarioNotificacao = horarioNotificacao;

  get getTempoAposOEpisodioParaDispararNotificacao => this.tempoAposOEpisodioParaDispararNotificacao;

  set setTempoAposOEpisodioParaDispararNotificacao( tempoAposOEpisodioParaDispararNotificacao) => this.tempoAposOEpisodioParaDispararNotificacao = tempoAposOEpisodioParaDispararNotificacao;
}