<?php
 
namespace App\Http\Controllers;
 
use App\Article;
use Illuminate\Http\Request;
 
class ArticleController extends Controller
{
   public function index()
   {
       $articles = Article::all();
       return view('article.index', compact('articles'));
   }
 
   public function show($id)
   {
        $article = Article::find($id);
        if(is_null($article)) {
            return \App::abort(404, $id);
        } else {
            return view('article.show', compact('article'));
        }
   }

   public function create()
   {
        return view('article.create');
   }
 
   public function edit($id)
   {
        $article = Article::find($id);
        if(is_null($article)) {
            return \App::abort(404, $id);
        } else {
            return view('article.edit', compact('article'));
        } 
   }
 
   public function store(Request $request)
   {
        $article = new Article();
        $article->title = $request->title;
        $article->body = $request->body;
        if(empty($request->image)) {
            $article->imagePath = 'uploads/noimage.png';
        } else {
            $file_name = time().$request->file('image')->getClientOriginalName();
            $article->imagePath = 'uploads/'.$file_name;
            $request->file('image')->storeAs('uploads', $file_name, 'public_uploads');
        }
        $article->save();
        return redirect()->route('article.index');
   }
 
   public function update($id, Request $request)
   {
       
        $article = Article::find($id);
        $article->title = $request->title;
        $article->body = $request->body;
        if($request->perm == 'false') {
            if(!empty($request->changedImage) ) {
                $file_name = time().$request->file('changedImage')->getClientOriginalName();
                $article->imagePath = 'uploads/'.$file_name;
                $request->file('changedImage')->storeAs('uploads', $file_name, 'public_uploads');
            } else {
                $article->imagePath = 'uploads/noimage.png';
            }
        }
        $article->save();
        return redirect()->route('article.index');
   }
 
   public function destroy(Request $request, $id)
   {
        $article = Article::find($id);
        $article->destroy($id);
        return redirect()->route('article.index');
   }
}
