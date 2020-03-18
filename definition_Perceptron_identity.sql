CREATE SCHEMA Perceptron_identity;
CREATE TYPE Perceptron_identity.fields AS (dimension int, weights numeric[], ranges Myrange[], learning_rate numeric);
CREATE OR REPLACE FUNCTION Perceptron_identity.construct(dimension int, learning_rate numeric) RETURNS Perceptron_identity.fields AS
$cf$
    DECLARE
        this Perceptron_identity.fields := null;
        min numeric; max numeric;   
    BEGIN
        this.dimension := dimension;
        FOR i IN 0 .. dimension LOOP -- weights‚Í0ƒIƒŠƒWƒ“
            this.weights[i] := random();
        END LOOP;
        this.learning_rate := learning_rate; 
        return this;
    END
$cf$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate(this Perceptron_identity.fields, inputs numeric[]) RETURNS int AS
$cf$
    DECLARE answer int;
    BEGIN
        SELECT D(this, inputs) INTO answer;
        return answer;
    END;
$cf$ LANGUAGE plpgsql;

/*
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
*/

CREATE OR REPLACE FUNCTION D(this Perceptron_identity.fields, inputs numeric[]) RETURNS numeric AS
$cf$
    DECLARE dot numeric;
    BEGIN 
        inputs:= 1.0 || inputs;
	return dot_(inputs, this.weights)
    END; 
$cf$ LANGUAGE plpgsql;
