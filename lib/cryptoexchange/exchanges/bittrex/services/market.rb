module Cryptoexchange::Exchanges
  module Bittrex
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            true
          end
        end

        def fetch(market_pair = nil)
          if market_pair
            output = super(ticker_url(market_pair))['result'][0]
            adapt(output, market_pair)
          else
            output = super(self.ticker_url)['result']
            adapt_all(output)
          end
        end

        def adapt_all(output)
          output.map do |market|
            # Target comes first in Bittrex ie. BTC-BCN
            # BTC cannot be a base in this pair
            target, base = market['MarketName'].split('-')
            market_pair = Cryptoexchange::Models::MarketPair.new(
                            base: base,
                            target: target,
                            market: Bittrex::Market::NAME
                          )

            adapt(market, market_pair)
          end
        end

        def ticker_url(market_pair = nil)
          if market_pair
            base = market_pair.base
            target = market_pair.target
            # Bittrex pair has BTC comes first, when BTC is typically a Target not a Base
            "#{Cryptoexchange::Exchanges::Bittrex::Market::API_URL}/public/getmarketsummary?market=#{target}-#{base}"
          else
            "#{Cryptoexchange::Exchanges::Bittrex::Market::API_URL}/public/getmarketsummaries"
          end
        end

        def adapt(output, market_pair)
          ticker = Cryptoexchange::Models::Ticker.new
          market = output

          ticker.base      = market_pair.base
          ticker.target    = market_pair.target
          ticker.market    = Bittrex::Market::NAME
          ticker.last      = NumericHelper.to_d(market['Last'])
          ticker.high      = NumericHelper.to_d(market['High'])
          ticker.low       = NumericHelper.to_d(market['Low'])
          ticker.ask       = NumericHelper.to_d(market['Ask'])
          ticker.bid       = NumericHelper.to_d(market['Bid'])
          ticker.volume    = NumericHelper.to_d(market['Volume'])
          ticker.timestamp = DateTime.now.to_time.to_i
          ticker.payload   = market
          ticker
        end
      end
    end
  end
end
