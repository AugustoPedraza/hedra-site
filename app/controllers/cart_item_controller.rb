class CartItemController < ApplicationController
  before_filter :resource, :only => [:create, :destroy]

  # TODO: Do I really need a full AR object for this?

  def create
    session['cart'] ||= {}
    if session['cart'][@book.id].nil?
      session['cart'][@book.id] = 1
    else
      session['cart'][@book.id] += 1
    end
    flash[:info] = "O livro <em>#{@book.title}</em> foi adicionado ao carrinho!"
    redirect_to :back
  end

  def update
  end

  def destroy
    session['cart'].delete(@book.id)
    redirect_to :back
  end

  private

  def resource
    @book = Book.find(params[:id])
  end
end