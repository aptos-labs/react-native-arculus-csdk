import { type CARD_ALGORITHMS, CARD_CURVES } from './constants';

type CardAlgorithmType = typeof CARD_ALGORITHMS;

export type CardAlgorithm = CardAlgorithmType[keyof CardAlgorithmType];

type CardCurveType = typeof CARD_CURVES;

export type CardCurve = CardCurveType[keyof CardCurveType];
