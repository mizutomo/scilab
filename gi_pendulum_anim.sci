// 単振り子アニメーションブロック用GUI関数
function [x, y, typ] = gi_pendulum_anim(job, arg1, arg2)
  x = []; y = []; typ = [];
//
  select job
//
  case "define" then              // ブロックデータ構造体の初期化
    // ブロックのパラメータの初期値
    lp = 4;                       // 振り子の長さ
    lw = 0.45;                    // 錘を表す正三角形の一辺の長さ
    model = scicos_model();
    model.sim = list("comp_pendulum_anim", 5);   // 関数名とタイプ
    model.in = [1];               // レギュラー入力ポートの個数とサイズ
    model.evtin = [1];            // イベント入力ポートの個数とサイズ
    model.out = [];               // 出力ポートの個数とサイズ
    model.dstate = [0];           // ブロックの離散時間状態ベクトルの初期値
    model.rpar = [lp; lw];        // ブロックの実数型のパラメータ
    exprs = string(model.rpar);   // 文字列として表現されたパラメータの初期値
    // ブロック内のアイコンを描く命令を文字列として格納する。
    gr_i = ["thick = xget(""thickness"");";
            "xset(""thickness"", 2);";
            "xx = orig(1) + sz(1)*[.3, .7];";
            "yy = orig(2) + sz(2)*[.8, .8];";
            "xpoly(xx, yy);";             // 天井を描く
            "xx = [.5, .5, .45, .5,  .55, .5];";
            "yy = [.8, .4, .4,  .35, .4,  .4];";
            "xy = rotate([xx; yy], %pi/6, [.5; .8]);";
            "xx = orig(1) + sz(1)*xy(1,:);";
            "yy = orig(2) + sz(2)*xy(2,:);";
            "xfpoly(xx, yy, 1);";         // リンクと錘を描く
            "xset(""thickness"", thick);"];
    sz = [3, 3];                  // ブロックの幅と高さを指定
    x = standard_define(sz, model, exprs, gr_i);
  //

  case "plot" then               // ブロックを描く
    standard_draw(arg1);         // 既定の矩形ブロックをScicosのウィンドウに描く
  //
  case "getorigin" then          // ブロックを表す矩形の左下隅のウィンドウ座標を指定する
    [x, y] = standard_origin(arg1);
  //
  case "getinputs" then          // 入力ポートの位置とタイプ(regular/event)を指定
    [x, y, typ] = standard_inputs(arg1);
  //
  case "getoutputs" then         // 出力ポートの位置とタイプ(regular/event)を指定
    [x, y, typ] = standard_outputs(args1);
  //

  case "set" then                // ダイアログウィンドウ表示とブロックパラメータの入力
    x = arg1;
    graphics = arg1.graphics;
    exprs    = graphics.exprs;
    model    = arg1.model;

    while %t do
      // ダイアログウィンドウを表示する
      [ok, lp, lw, exprs] = getvalue(..
          "Pendulum parameters ", ..
          ["pendulum length"; ..
          "wheight size (length of a side)"],..
          list("vec", 1, "vec", 1), exprs);
      if ~ok then      // Dismissボタンが押された場合
        break;
      end

      msg = [];        // 入力値が正当であるか確認する
      if lp <= 0 | lw <= 0 then
        msg = [msg; ..
        "Pendulum length and weight size must be positive."];
        ok = %f;
      end

      if ok then       // 入力値が正当であれば、ブロックデータ構造体を更新
        model.rpar = [lp; lw];
        graphics.exprs = exprs;
        x.graphics = graphics;
        x.model = model;
        break;
      else
        message(msg);
      end
    end   // end of while

  end // end of select-case
endfunction
