-- 配列の先頭インデックスを変更する
CREATE OR REPLACE FUNCTION originize(origin int, arr anyarray) RETURNS anyarray AS
$cf$
    DECLARE length int := array_length(arr, 1);
    BEGIN
        IF arr::text ~ '^\[.*' THEN
            return ('['|| origin || ':' || length+(origin-1) || ']=' || substring(arr::text from '^\[[^]]*]=(.*)$'));
        ELSE
            return ('['|| origin || ':' || length+(origin-1) || ']=' || arr::text);
        END IF;
    END;
$cf$ LANGUAGE plpgsql;

-- 配列の先頭インデックスをずらす(相対的に変更する)
CREATE OR REPLACE FUNCTION originize_relative(d_origin int, arr anyarray) RETURNS anyarray AS
$cf$
    DECLARE current_origin int;
    BEGIN
        IF arr::text ~ '^\[.*' THEN
            current_origin := substring(arr::text from '^\[(.*):.*$');
        ELSE
            current_origin := 1;
        END IF;
        return originize(d_origin+current_origin, arr);
    END;
$cf$ LANGUAGE plpgsql;


CREATE SCHEMA Perceptron_sigmoid;
CREATE SCHEMA Perceptron_identity;

CREATE TYPE Perceptron_sigmoid.fields AS (dimension int, weights numeric[], learning_rate numeric);
CREATE TYPE Perceptron_identity.fields AS (dimension int, weights numeric[], learning_rate numeric);

CREATE OR REPLACE FUNCTION Perceptron_sigmoid.construct(dimension int, learning_rate numeric) RETURNS Perceptron_sigmoid.fields AS
$cf$
    DECLARE
        this Perceptron_sigmoid.fields := null;
        min numeric; max numeric;   
    BEGIN
        this.dimension := dimension;
        FOR i IN 0 .. dimension LOOP -- weightsは0オリジン
            this.weights[i] := random();
        END LOOP;
        this.learning_rate := learning_rate; 
        return this;
    END
$cf$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION Perceptron_identity.construct(dimension int, learning_rate numeric) RETURNS Perceptron_identity.fields AS
$cf$
    DECLARE
        this Perceptron_identity.fields := null;
        min numeric; max numeric;   
    BEGIN
        this.dimension := dimension;
        FOR i IN 0 .. dimension LOOP -- weightsは0オリジン
            this.weights[i] := random();
        END LOOP;
        this.learning_rate := learning_rate; 
        return this;
    END
$cf$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Perceptron_sigmoid.construct(dimension int, learning_rate numeric) RETURNS Perceptron_sigmoid.fields AS
$cf$
    DECLARE
        this Perceptron_sigmoid.fields := null;
        min numeric; max numeric;   
    BEGIN
        this.dimension := dimension;
        FOR i IN 0 .. dimension LOOP -- weightsは0オリジン
            this.weights[i] := random();
        END LOOP;
        this.learning_rate := learning_rate; 
        return this;
    END
$cf$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION Perceptron_identity.construct(dimension int, learning_rate numeric) RETURNS Perceptron_identity.fields AS
$cf$
    DECLARE
        this Perceptron_identity.fields := null;
        min numeric; max numeric;   
    BEGIN
        this.dimension := dimension;
        FOR i IN 0 .. dimension LOOP -- weightsは0オリジン
            this.weights[i] := random();
        END LOOP;
        this.learning_rate := learning_rate; 
        return this;
    END
$cf$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate(this Perceptron_sigmoid.fields, inputs numeric[]) RETURNS int AS
$cf$
    DECLARE answer int;
    BEGIN
        SELECT D(this, inputs) INTO answer;
        return answer;
    END;
$cf$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION calculate(this Perceptron_identity.fields, inputs numeric[]) RETURNS int AS
$cf$
    DECLARE answer int;
    BEGIN
        SELECT D(this, inputs) INTO answer;
        return answer;
    END;
$cf$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION dot_(vector1 numeric[], vector2 numeric[]) RETURNS numeric AS
$cf$
    DECLARE ans numeric := 0;
    BEGIN
        vector1 := originize(1, vector1);
        vector2 := originize(1, vector2);
        FOR idx IN 1..(array_length(vector1, 1)) LOOP
            ans := ans + vector1[idx]*vector2[idx];
        END LOOP;
        return ans;
    END;
$cf$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION D(this Perceptron_sigmoid.fields, inputs numeric[]) RETURNS numeric AS
$cf$
    DECLARE dot numeric;
    BEGIN 
        inputs:= 1.0 || inputs;
        dot := dot_(inputs, this.weights); --内積
	return sigmoid(dot); --低速高精度(1000桁)
      --return (1+exp(-dot))^(-1); --高速低精度
    END; 
$cf$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION D(this Perceptron_identity.fields, inputs numeric[]) RETURNS numeric AS
$cf$
    DECLARE dot numeric;
    BEGIN 
        inputs:= 1.0 || inputs;
        return dot_(inputs, this.weights);
    END; 
$cf$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION sigmoid(n numeric) RETURNS numeric AS
$cf$
    DECLARE
        exp numeric = 2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274274663919320030599218174135966290435729003342952605956307381323286279434907632338298807531952510190115738341879307021540891499348841675092447614606680822648001684774118537423454424371075390777449920695517027618386062613313845830007520449338265602976067371132007093287091274437470472306969772093101416928368190255151086574637721112523897844250569536967707854499699679468644549059879316368892300987931277361782154249992295763514822082698951936680331825288693984964651058209392398294887933203625094431173012381970684161403970198376793206832823764648042953118023287825098194558153017567173613320698112509961818815930416903515988885193458072738667385894228792284998920868058257492796104841984443634632449684875602336248270419786232090021609902353043699418491463140934317381436405462531520961836908887070167683964243781405927145635490613031072085103837505101157477041718986106873969655212671546889570350354;
    BEGIN
        return (1+exp^(-n))^(-1);
    END;
$cf$ LANGUAGE plpgsql;