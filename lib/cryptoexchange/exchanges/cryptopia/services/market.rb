module Cryptoexchange::Exchanges
  module Cryptopia
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            true
          end
        end

        def fetch(market_pair = nil)
          if market_pair
            output = super(ticker_url(market_pair))['Data']
            adapt(output, market_pair)
          else
            output = super(self.ticker_url)['Data']
            adapt_all(output)
          end
        end

        def adapt_all(output)
          output.map do |market|
            base, target = market['Label'].split('/')
            market_pair = Cryptoexchange::Models::MarketPair.new(
                            base: base,
                            target: target,
                            market: Cryptopia::Market::NAME
                          )

            adapt(market, market_pair)
          end
        end

        def ticker_url(market_pair = nil)
          if market_pair
            base = market_pair.base
            target = market_pair.target
            "#{Cryptoexchange::Exchanges::Cryptopia::Market::API_URL}/GetMarket/#{base}_#{target}"
          else
            "#{Cryptoexchange::Exchanges::Cryptopia::Market::API_URL}/GetMarkets/"
          end
        end

        def adapt(output, market_pair)
          ticker           = Cryptoexchange::Models::Ticker.new

          ticker.base      = market_pair.base
          ticker.target    = market_pair.target
          ticker.market    = Cryptopia::Market::NAME
          ticker.last      = NumericHelper.to_d(output['LastPrice'])
          ticker.bid       = NumericHelper.to_d(output['BidPrice'])
          ticker.ask       = NumericHelper.to_d(output['AskPrice'])
          ticker.high      = NumericHelper.to_d(output['High'])
          ticker.low       = NumericHelper.to_d(output['Low'])
          ticker.volume    = NumericHelper.to_d(output['Volume'])
          ticker.change    = NumericHelper.to_d(output['Change'])
          ticker.timestamp = Time.now.to_i
          ticker.payload   = output
          ticker
        end
      end
    end
  end
end
